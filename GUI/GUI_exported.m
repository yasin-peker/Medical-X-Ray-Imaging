%% 
classdef GUI_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        TabGroup                        matlab.ui.container.TabGroup
        ProjectionTab                   matlab.ui.container.Tab
        InputImageEditField             matlab.ui.control.EditField
        InputImageEditFieldLabel        matlab.ui.control.Label
        RunButton                       matlab.ui.control.Button
        ShowAngleEditField              matlab.ui.control.NumericEditField
        ShowAngleEditFieldLabel         matlab.ui.control.Label
        RotationAngleEditField          matlab.ui.control.NumericEditField
        RotationAngleEditFieldLabel     matlab.ui.control.Label
        StepSizeEditField               matlab.ui.control.NumericEditField
        StepSizeEditFieldLabel          matlab.ui.control.Label
        NumberofBeamsEditField          matlab.ui.control.NumericEditField
        NumberofBeamsEditFieldLabel     matlab.ui.control.Label
        ProjectionApplicationLabel      matlab.ui.control.Label
        UIAxes                          matlab.ui.control.UIAxes
        BackprojectionTab               matlab.ui.container.Tab
        MSEEditField                    matlab.ui.control.NumericEditField
        MSEEditFieldLabel               matlab.ui.control.Label
        RunButton_2                     matlab.ui.control.Button
        FilterTypeEditField             matlab.ui.control.EditField
        FilterTypeEditFieldLabel        matlab.ui.control.Label
        BackProjectionApplicationLabel  matlab.ui.control.Label
        UIAxes2_2                       matlab.ui.control.UIAxes
        UIAxes2                         matlab.ui.control.UIAxes
    end

    
    properties (Access = public)
        imgDir;
        BeamNumber;
        SizeOfStep;
        showAngle;
        projections;
        M;
        myImg;
        p_vals;
        filterType;
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: RunButton
        function RunButtonPushed(app, event)
            app.imgDir = app.InputImageEditField.Value;
            app.BeamNumber = app.NumberofBeamsEditField.Value;
            app.SizeOfStep = app.StepSizeEditField.Value;
            RotationAngle = app.RotationAngleEditField.Value;
            app.showAngle = app.ShowAngleEditField.Value;
            [app.projections, app.M, app.myImg] = projection(app.imgDir,app.BeamNumber,app.SizeOfStep,RotationAngle);
            app.projections = app.projections';
            if mod(app.BeamNumber,2) == 0
                app.p_vals = -floor((app.BeamNumber)/2) : floor((app.BeamNumber)/2) - 1;
            else
                app.p_vals = -floor((app.BeamNumber-1)/2) : floor((app.BeamNumber-1)/2);
            end
            app.p_vals = app.p_vals';
            
            plot(app.UIAxes, app.p_vals, app.projections(:, app.showAngle));
            
            title(app.UIAxes,['Projection at theta = ' num2str(app.showAngle)]);
            xlabel(app.UIAxes,'$p$-values');
        end

        % Value changed function: FilterTypeEditField
        function FilterTypeEditFieldValueChanged(app, event)
            app.filterType = app.FilterTypeEditField.Value;
            app.filterType = string(app.filterType);
        end

        % Button pushed function: RunButton_2
        function RunButton_2Pushed(app, event)
            if app.filterType == "no-filter"
                [~, square_recons_0_nofilter] = backprojection(app.projections', ...
                    app.M, app.myImg, "triang");
                square_recons_0_nofilter = square_recons_0_nofilter / max(max(square_recons_0_nofilter));
                square = cell2mat(struct2cell(load('square.mat')));
                square = square / max(max(square));
      
                imshow(square, 'parent', app.UIAxes2)
                title(app.UIAxes2,'Original Image')
                imshow(square_recons_0_nofilter, 'parent', app.UIAxes2_2)
                title(app.UIAxes2_2, {'Reconstructed Image', 'without Filtering'})
                app.MSEEditField.Value = sum(sum((square - square_recons_0_nofilter).^2)) / numel(square);

            elseif app.filterType == "triang"
                [square_recons_1_filterNoWindow] = backprojection(app.projections', ...
                    app.M, app.myImg, app.filterType);
                square_recons_1_filterNoWindow = square_recons_1_filterNoWindow / max(max(square_recons_1_filterNoWindow));
                square = cell2mat(struct2cell(load('square.mat')));
                square = square / max(max(square));
      
                imshow(square, 'parent', app.UIAxes2)
                title(app.UIAxes2,'Original Image')
                imshow(square_recons_1_filterNoWindow, 'parent', app.UIAxes2_2)
                title(app.UIAxes2_2, {'Reconstructed Image', 'with Triang Filtering'})
                app.MSEEditField.Value = sum(sum((square - square_recons_1_filterNoWindow).^2)) / numel(square);
            elseif app.filterType == "hann"
                [square_recons_2_filterCosine] = backprojection(app.projections', ...
                    app.M, app.myImg, app.filterType);
                square_recons_2_filterCosine = square_recons_2_filterCosine / max(max(square_recons_2_filterCosine));
                square = cell2mat(struct2cell(load('square.mat')));
                square = square / max(max(square));
      
                imshow(square, 'parent', app.UIAxes2)
                title(app.UIAxes2,'Original Image')
                imshow(square_recons_2_filterCosine, 'parent', app.UIAxes2_2)
                title(app.UIAxes2_2, {'Reconstructed Image', 'with Hann Filtering'})
                app.MSEEditField.Value = sum(sum((square - square_recons_2_filterCosine).^2)) / numel(square);
            elseif app.filterType == "blackman"
                [square_recons_2_filterCosine] = backprojection(app.projections', ...
                    app.M, app.myImg, app.filterType);
                square_recons_2_filterCosine = square_recons_2_filterCosine / max(max(square_recons_2_filterCosine));
                square = cell2mat(struct2cell(load('square.mat')));
                square = square / max(max(square));
      
                imshow(square, 'parent', app.UIAxes2)
                title(app.UIAxes2,'Original Image')
                imshow(square_recons_2_filterCosine, 'parent', app.UIAxes2_2)
                title(app.UIAxes2_2, {'Reconstructed Image', 'with Blackman Filtering'})
                app.MSEEditField.Value = sum(sum((square - square_recons_2_filterCosine).^2)) / numel(square);
            end

        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [1 1 640 480];

            % Create ProjectionTab
            app.ProjectionTab = uitab(app.TabGroup);
            app.ProjectionTab.Title = 'Projection';
            app.ProjectionTab.BackgroundColor = [0.902 0.902 0.902];

            % Create UIAxes
            app.UIAxes = uiaxes(app.ProjectionTab);
            title(app.UIAxes, 'Title')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [246 102 351 286];

            % Create ProjectionApplicationLabel
            app.ProjectionApplicationLabel = uilabel(app.ProjectionTab);
            app.ProjectionApplicationLabel.HorizontalAlignment = 'center';
            app.ProjectionApplicationLabel.FontSize = 14;
            app.ProjectionApplicationLabel.FontWeight = 'bold';
            app.ProjectionApplicationLabel.Position = [219 411 202 23];
            app.ProjectionApplicationLabel.Text = 'Projection Application';

            % Create NumberofBeamsEditFieldLabel
            app.NumberofBeamsEditFieldLabel = uilabel(app.ProjectionTab);
            app.NumberofBeamsEditFieldLabel.BackgroundColor = [0.8 0.8 0.8];
            app.NumberofBeamsEditFieldLabel.Position = [8 304 102 22];
            app.NumberofBeamsEditFieldLabel.Text = 'Number of Beams';

            % Create NumberofBeamsEditField
            app.NumberofBeamsEditField = uieditfield(app.ProjectionTab, 'numeric');
            app.NumberofBeamsEditField.BackgroundColor = [0.8 0.8 0.8];
            app.NumberofBeamsEditField.Position = [125 304 100 22];

            % Create StepSizeEditFieldLabel
            app.StepSizeEditFieldLabel = uilabel(app.ProjectionTab);
            app.StepSizeEditFieldLabel.BackgroundColor = [0.8 0.8 0.8];
            app.StepSizeEditFieldLabel.Position = [8 258 57 22];
            app.StepSizeEditFieldLabel.Text = 'Step Size';

            % Create StepSizeEditField
            app.StepSizeEditField = uieditfield(app.ProjectionTab, 'numeric');
            app.StepSizeEditField.BackgroundColor = [0.8 0.8 0.8];
            app.StepSizeEditField.Position = [125 258 100 22];

            % Create RotationAngleEditFieldLabel
            app.RotationAngleEditFieldLabel = uilabel(app.ProjectionTab);
            app.RotationAngleEditFieldLabel.BackgroundColor = [0.8 0.8 0.8];
            app.RotationAngleEditFieldLabel.Position = [8 216 83 22];
            app.RotationAngleEditFieldLabel.Text = 'Rotation Angle';

            % Create RotationAngleEditField
            app.RotationAngleEditField = uieditfield(app.ProjectionTab, 'numeric');
            app.RotationAngleEditField.BackgroundColor = [0.8 0.8 0.8];
            app.RotationAngleEditField.Position = [125 216 100 22];

            % Create ShowAngleEditFieldLabel
            app.ShowAngleEditFieldLabel = uilabel(app.ProjectionTab);
            app.ShowAngleEditFieldLabel.BackgroundColor = [0.8 0.8 0.8];
            app.ShowAngleEditFieldLabel.Position = [8 178 83 22];
            app.ShowAngleEditFieldLabel.Text = 'Show Angle';

            % Create ShowAngleEditField
            app.ShowAngleEditField = uieditfield(app.ProjectionTab, 'numeric');
            app.ShowAngleEditField.BackgroundColor = [0.8 0.8 0.8];
            app.ShowAngleEditField.Position = [125 178 100 22];

            % Create RunButton
            app.RunButton = uibutton(app.ProjectionTab, 'push');
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @RunButtonPushed, true);
            app.RunButton.BackgroundColor = [0.651 0.651 0.651];
            app.RunButton.Position = [57 114 100 22];
            app.RunButton.Text = 'Run';

            % Create InputImageEditFieldLabel
            app.InputImageEditFieldLabel = uilabel(app.ProjectionTab);
            app.InputImageEditFieldLabel.BackgroundColor = [0.8 0.8 0.8];
            app.InputImageEditFieldLabel.Position = [8 352 69 22];
            app.InputImageEditFieldLabel.Text = 'Input Image';

            % Create InputImageEditField
            app.InputImageEditField = uieditfield(app.ProjectionTab, 'text');
            app.InputImageEditField.BackgroundColor = [0.8 0.8 0.8];
            app.InputImageEditField.Placeholder = 'name of input';
            app.InputImageEditField.Position = [125 352 100 22];

            % Create BackprojectionTab
            app.BackprojectionTab = uitab(app.TabGroup);
            app.BackprojectionTab.Title = 'Backprojection';
            app.BackprojectionTab.BackgroundColor = [0.902 0.902 0.902];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.BackprojectionTab);
            title(app.UIAxes2, 'Title')
            xlabel(app.UIAxes2, 'X')
            ylabel(app.UIAxes2, 'Y')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.Position = [14 111 282 242];

            % Create UIAxes2_2
            app.UIAxes2_2 = uiaxes(app.BackprojectionTab);
            title(app.UIAxes2_2, 'Title')
            xlabel(app.UIAxes2_2, 'X')
            ylabel(app.UIAxes2_2, 'Y')
            zlabel(app.UIAxes2_2, 'Z')
            app.UIAxes2_2.Position = [325 102 293 251];

            % Create BackProjectionApplicationLabel
            app.BackProjectionApplicationLabel = uilabel(app.BackprojectionTab);
            app.BackProjectionApplicationLabel.HorizontalAlignment = 'center';
            app.BackProjectionApplicationLabel.FontSize = 14;
            app.BackProjectionApplicationLabel.FontWeight = 'bold';
            app.BackProjectionApplicationLabel.Position = [219 411 202 23];
            app.BackProjectionApplicationLabel.Text = 'Back Projection Application';

            % Create FilterTypeEditFieldLabel
            app.FilterTypeEditFieldLabel = uilabel(app.BackprojectionTab);
            app.FilterTypeEditFieldLabel.BackgroundColor = [0.8 0.8 0.8];
            app.FilterTypeEditFieldLabel.HorizontalAlignment = 'right';
            app.FilterTypeEditFieldLabel.Position = [46 373 61 22];
            app.FilterTypeEditFieldLabel.Text = 'Filter Type';

            % Create FilterTypeEditField
            app.FilterTypeEditField = uieditfield(app.BackprojectionTab, 'text');
            app.FilterTypeEditField.ValueChangedFcn = createCallbackFcn(app, @FilterTypeEditFieldValueChanged, true);
            app.FilterTypeEditField.BackgroundColor = [0.8 0.8 0.8];
            app.FilterTypeEditField.Placeholder = 'triang';
            app.FilterTypeEditField.Position = [122 373 65 22];
            app.FilterTypeEditField.Value = 'triang';

            % Create RunButton_2
            app.RunButton_2 = uibutton(app.BackprojectionTab, 'push');
            app.RunButton_2.ButtonPushedFcn = createCallbackFcn(app, @RunButton_2Pushed, true);
            app.RunButton_2.BackgroundColor = [0.651 0.651 0.651];
            app.RunButton_2.Position = [57 64 100 22];
            app.RunButton_2.Text = 'Run';

            % Create MSEEditFieldLabel
            app.MSEEditFieldLabel = uilabel(app.BackprojectionTab);
            app.MSEEditFieldLabel.HorizontalAlignment = 'right';
            app.MSEEditFieldLabel.Position = [420 64 31 22];
            app.MSEEditFieldLabel.Text = 'MSE';

            % Create MSEEditField
            app.MSEEditField = uieditfield(app.BackprojectionTab, 'numeric');
            app.MSEEditField.Position = [466 64 100 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = GUI_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end