function [Projected, M, myImg] = projection(imgDir, BeamNumber, SizeOfStep, RotationAngle, verbose)
%% Projection Function Definition
% Summary of the function:
% projection function calculates projections of an input image from
% different angles. Also, it can calculate projections of a rotated image.

% Detailed explanation of the projection function:
% projection function takes 4 inputs and gives 3 outputs.

% Inputs:

% imgDir -> Directory of the image to be projected. The format of the image 
% must be in apostrophe. For example, to input the test image, you should 
% write imgDir as 'square.mat' 

% BeamNumber -> Number of sampling points in each projection. 
% It should be integer.

% SizeOfStep -> Projection angle step size. It should be integer.

% RotationAngle -> Angle to rotate the input image as desired. For example,
% to rotate input image by 90 degrees, RotationAngle must be entered as 90.
% It should be integer.

% Outputs:

% Projected -> Calculated projections according to the BeamNumber,
% SizeOfStep and RotationAngle.

% M -> Size of the input image.

% myImg -> Uploaded input image.

%% Uploading the Image

myImg = cell2mat(struct2cell(load(imgDir)));
myImg = myImg / max(max(myImg));
% inputImg output is the input image with a desired rotation angle applied.
myImg = imrotate(myImg,RotationAngle);
if nargin == 5
    imshow(myImg)
    title(strcat('Input Image with Rotation: ', num2str(RotationAngle)));
end
% First index of the size gives the size = M variable. 
% Second index is not used because it gives the same result.
[M, secondIndex] = size(myImg);

%% Definition of Input Parameters
% numberOfBeams and stepSize are decided by the user.
numberOfBeams = BeamNumber;
stepSize = SizeOfStep;
% "numberOfBeams" times "t" values between [-M/sqrt(2), M/sqrt(2)] created.
t = linspace(-M/sqrt(2), M/sqrt(2), numberOfBeams);
% "theta" values from 0 to 180-stepSize by increasing 180/stepSize created.
theta = linspace(0,180-stepSize, 180/stepSize);

%% Initialization of Variables
% Definition of X and Y ranges
X = -M/2:M/2;
Y = -M/2:M/2;

% The resultant "Projected" matrix is initialized.
% Size of this matrix is [theta,t]. 
Projected = zeros(length(theta), length(t));

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

        % Unique coordinates are determined since there are multiple 
        % duplicate coordinates.
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

        %% Sum all Pixel Value and Distance Products
        for idxRowData = 1:length(rowdata)
            Projected(i,ii) = Projected(i,ii) + Distance(idxRowData) * myImg(rowdata(idxRowData), columndata(idxRowData));
        end 
    end
end
%% Plots of the Outputs

if nargin == 5
    sizeOfFig=1;
    projectionPlots = figure;
    
    % projectionPlots are the plots of the projections with different angles.
    for plotIdx = round(1:length(theta)/4:length(theta)) 
         subplot(2,2,sizeOfFig); 
         plot(1:numberOfBeams,Projected(plotIdx,:))
         xlabel('Number of Beams');
         ylabel('P(theta)');
         title(strcat('Theta: ',' ',num2str(theta(plotIdx))));
         sizeOfFig = sizeOfFig+1;
    end
end
end