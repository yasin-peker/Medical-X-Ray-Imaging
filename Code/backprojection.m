function [Backprojected, BackprojectedWithoutFilter,meanSquaredError,ssimScore,psnrScore] = backprojection(projectionData, M, myImg, filterType, verbose)
    %% Backprojection Function Definition
    % backprojection function calculates backprojections of an input projection
    % data from different angles.
    
    % Detailed explanation of the projection function:
    % projection function takes 4 inputs and gives 2 outputs.
    
    % Inputs:
    
    % projectionData -> Projection data which is the output of the "projection.m" function. 
    % The projectionData is a variable. In order to obtain this variable,
    % firstly the "projection.m" function must be called, then
    % "backprojection.m" function must be called. If projection.m function is
    % not used, then type the name of the projection data in double quotes.
    
    % M -> Size of the input image. If the projection.m function is used first,
    % then there is no need to specify its value. Instead, just type the
    % variable name that you use for the output of the projection.m function.
    % If projection.m function is not used, then type the size of the input
    % image.
    
    % myImg -> Uploaded input image. If the projection.m function is used first,
    % then there is no need to specify its value. Instead, just type the
    % variable name that you use for the output of the projection.m function.
    % If projection.m function is not used, then type the name of the input
    % image in double quotes.
    
    % filterType -> The type of the filter that is going to be implemented.
    % 3 different types of filters are applied. These filters are:
    
    % Triangular Window: "triang"
    % Hann (Hanning) Window: "hann"
    % Blackman Window: "blackman" 
    
    % In order to use the desired type of filter, the string in double quotes
    % must be entered into the parameter filterType.
    % For example, if user wants to use hann filter, then user must type 
    % "hann" as the fourth parameter of the backprojection function.
    
    % Output:
    
    % Backprojected -> Output of the backprojection function which is the
    % backprojected version of the input projection data.
    
    % BackprojectedWithoutFilter -> Output of the backprojection function which 
    % is the unfiltered backprojected version of the input projection data.
    
    %% Uploading the Projection Data
    % Check whether the output of the projection.m function is used.
    if class(projectionData) == "double"
        myProjection = projectionData;
    % Load the projection data different from the output of the projection.m
    else
        projectionData = cell2mat(struct2cell(load(projectionData)));
        myProjection = projectionData;
    end
    
    % Check whether the output of the projection.m function is used.
    if class(myImg) == "double"
        dummVar = 0;
    % Load the input image different from the output of the projection.m
    else
        myImg = cell2mat(struct2cell(load(myImg)));
    end
    
    % First index of the size gives the size = M variable. 
    % Second index is not used because it gives the same result.
    [stepSize, numberOfBeams] = size(myProjection);
    %% Definition of Input Parameters
    % "numberOfBeams" times "t" values between [-M/sqrt(2), M/sqrt(2)] created.
    t = linspace(-M/sqrt(2), M/sqrt(2), numberOfBeams);
    % "theta" values from 0 to 180-stepSize by increasing 180/stepSize created.
    theta = linspace(0,180-180/stepSize, stepSize);
    
    % Create a variable to hold the projection data to calculate the
    % backprojection without a filter.
    myProjectionWithoutFilter = myProjection;
    
    filterType = string(filterType);
    %% Initialization of the Filter
    if filterType == "triang"
        filter = fftshift(triang(numberOfBeams),2);
    elseif filterType == "hann"
        filter = fftshift(hann(numberOfBeams),1);
    elseif filterType == "blackman"
        filter = fftshift(blackman(numberOfBeams),1);
    end
    %% Implementation of the Filters
    window = fftshift(triang(numberOfBeams),2);
    
    for i=1:stepSize
        if filterType == "triang"
            myProjection(i,:) = ifft(fft(myProjection(i,:)) .* filter');
        else
        myProjection(i,:) = ifft(fft(myProjection(i,:)) .* filter'.* window');
        end
    end
    myProjection = real(myProjection);

    %% Initialization of Variables
    % Definition of X and Y ranges
    X = -M/2:M/2;
    Y = -M/2:M/2;
    
    % Initialize the Backprojected Matrix.
    Backprojected = zeros(M,M);
    % Initialize the Backprojected Without Filter Matrix.
    BackprojectedWithoutFilter = zeros(M,M);
    
    % Initialize the calculated total length as 0.
    lengthCalculated = 0;
    % IntersectionX and IntersectionX matrices are initialized.
    % These matrices are the result of the line equation.
    IntersectionX = zeros(length(X),2);
    IntersectionY = zeros(length(Y),2);
    
    % Combination of IntersectionX and IntersectionY matrices.
    CombinedIntersections = zeros(2*length(X),2);
    
    % For loop for each element of the "theta". 
    for i=1:length(theta)
        % For loop for each element of the "t". 
        for ii=1:length(t)
            %% Intersection Points for All Projection Angles
            % "col" is defined to specify which column is used for X values and
            % Y values.
            col = 1;
            for idxX=1:length(X)
                IntersectionY(idxX,col) = X(idxX);
                % Using X values, corresponding Y values are found
                IntersectionY(idxX,col+1) = ( t(ii) - X(idxX) * cosd(theta(i))) / sind(theta(i));
            end
    
            for idxY=1:length(Y)
                % Using Y values, corresponding X values are found
                IntersectionX(idxY,col+1) = Y(idxY);
                IntersectionX(idxY,col) = ( t(ii) - Y(idxY) * sind(theta(i))) / cosd(theta(i));
            end
           
            CombinedIntersections = [IntersectionY; IntersectionX];
    
            %% Irrelevant Points Detection
            for idx1=1:size(CombinedIntersections,1)
                for idx2=1:size(CombinedIntersections,2)
                    % dummVar is created to put argument into the if statement.
                    dummVar = 0;
                    if ( (CombinedIntersections(idx1,idx2) < -M/2) || (CombinedIntersections(idx1,idx2) > M/2) )
                        CombinedIntersections(idx1,idx2) = NaN;
                    else
                        dummVar = dummVar*1;
                    end
                end
            end
    
            % Any NaN value included rows are removed
            CombinedIntersections(any(isnan(CombinedIntersections), 2), :) = [];
           
            %% Sorting the Rows
            % New Merged Intersection Coordinates is sorted with respect to the rows
            SortedIntersectCoords = round(sortrows(CombinedIntersections),5);
    
            % Unique coordinates are determined since there are multiple duplicate
            % coordinates
            SortedIntersectCoords = unique(SortedIntersectCoords, 'rows');
           
            %% Distance Calculation
            % Distance Formula: dist = sqrt( (x2-x1)^2 + (y2-y1)^2 )
            % Midpoint Formula: mid = ( (x1+x2)/2, (y1+y2)/2 )   
            SizeOfCoords = size(SortedIntersectCoords); % Size of the coordinates vectors is 5x2
            % Initialize Distance and Midpoint Vectors with zeros
            Distance = zeros(1, SizeOfCoords(1,1)-1);
            MidPointsX = zeros(1, SizeOfCoords(1,1)-1);
            MidPointsY = zeros(1, SizeOfCoords(1,1)-1);
    
            for DistIndx = 1:1:(SizeOfCoords(1,1)-1)
                % If it is an empty matrix.
                if SizeOfCoords(1,1) < 1
                    SumOfSquaresX = 0;
                    SumOfSquaresY = 0;
                    Distance(DistIndx) = 0;
                    MidPointsX(DistIndx) = 0;
                    MidPointsY(DistIndx) = 0;
                % If there is only one value in a matrix.
                elseif SizeOfCoords(1,1) == 1
                    SumOfSquaresX = 0;
                    SumOfSquaresY = 0;
                    Distance(DistIndx) = 0;
                    MidPointsX(DistIndx) = SortedIntersectCoords(1,1);
                    MidPointsY(DistIndx) = SortedIntersectCoords(1,2);
                % For matrices with more than one value.
                else
                    SumOfSquaresX = (SortedIntersectCoords(DistIndx+1,1)-SortedIntersectCoords(DistIndx,1) )^2;
                    SumOfSquaresY = (SortedIntersectCoords(DistIndx+1,2)-SortedIntersectCoords(DistIndx,2) )^2;
                    Distance(DistIndx) = sqrt(SumOfSquaresX +SumOfSquaresY);
        
                    SumOfIndicesX = SortedIntersectCoords(DistIndx+1,1) + SortedIntersectCoords(DistIndx,1);
                    SumOfIndicesY = SortedIntersectCoords(DistIndx+1,2) + SortedIntersectCoords(DistIndx,2);
                    MidPointsX(DistIndx) = SumOfIndicesX/2;
                    MidPointsY(DistIndx) = SumOfIndicesY/2;
                end
            end
    
            %% Detect the Addres by Using Midpoint Data
            % rowdata = (M/2) - floor(middleYpoints)
            % columndata = (M/2) + ceil(middleXpoints)
            rowdata = int64((M/2) - floor(MidPointsY));
            columndata = int64((M/2) + ceil(MidPointsX));
            %% Calculate the Total Length
            lengthCalculated = lengthCalculated + length(Distance);
            % Calculation of the Backprojection 
            for idxRowData = 1:length(rowdata)
                Backprojected(rowdata(idxRowData),columndata(idxRowData)) = Backprojected(rowdata(idxRowData),...
                    columndata(idxRowData)) + myProjection(i,ii) * Distance(idxRowData);
                BackprojectedWithoutFilter(rowdata(idxRowData),columndata(idxRowData)) = BackprojectedWithoutFilter(rowdata(idxRowData),...
                    columndata(idxRowData)) + myProjectionWithoutFilter(i,ii) * Distance(idxRowData);
            end
        end
    end
    
    %% Plot the Back Projected Output Without a Filter
    % Element-wise Right Division
    BackprojectedWithoutFilter = BackprojectedWithoutFilter./max(BackprojectedWithoutFilter(:));
    % Create a new figure for the BackProjection Plot
    if nargin == 5
        figure;
        % Display image with scaled colors
        imagesc(abs(BackprojectedWithoutFilter));
        % Colormap is chosen in grayscale
        colormap gray
        % Add a colorbar to show the levels corresponding to the levels
        colorbar
        title('Back Projection without a Filter');
        
        % Mean-Squared Error: Calculates the Mean-Squared Error between the
        % Backprojected Output without a filter and the Input Image. Lower MSE means 
        % greater similarty between these two arrays. 
        meanSquaredErrorWithoutFilter = immse(BackprojectedWithoutFilter, myImg)
        
        % SSIM: Structural Similarity index for measuring the image quality. 
        % An SSIM score close to 1 indicates better image.
        ssimScoreWithoutFilter = ssim(BackprojectedWithoutFilter, myImg)
        
        % PSNR: Calculates the Peak Signal-to-Noise Ratio between the Backprojected
        % Output without a filter and the Input Image. A greater PSNR value means 
        % better image quality.
        psnrScoreWithoutFilter = psnr(BackprojectedWithoutFilter, myImg)
    end
    %% Plot the Back Projected Output with Filter
    % Element-wise Right Division
    Backprojected = Backprojected./max(Backprojected(:));
    % Create a new figure for the BackProjection Plot
    if nargin == 5
        figure;
        % Display image with scaled colors
        imagesc(abs(Backprojected));
        % Colormap is chosen in grayscale
        colormap gray
        % Add a colorbar to show the levels corresponding to the levels
        colorbar
        title('Back Projection with Filter:', filterType);
        
        % Mean-Squared Error: Calculates the Mean-Squared Error between the
        % Backprojected Output and the Input Image. Lower MSE means greater
        % similarty between these two arrays. 
        meanSquaredError = immse(Backprojected, myImg)
        
        % SSIM: Structural Similarity index for measuring the image quality. 
        % An SSIM score close to 1 indicates better image.
        ssimScore = ssim(Backprojected, myImg)
        
        % PSNR: Calculates the Peak Signal-to-Noise Ratio between the Backprojected
        % Output and the Input Image. A greater PSNR value means better image
        % quality.
        psnrScore = psnr(Backprojected, myImg)
    end
end