%%
% SpotDetectionAndColocalizationGUI.
% Copyright (C) 2017 J. Stegmaier, M. Schwarzkopf, H. Choi, A. Cunha
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%     http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%
% Please refer to the documentation for more information about the software
% as well as for installation instructions.
%
% If you use this application for your work, please cite the repository and one
% of the following publications:
%
% Bartschat, A.; Hübner, E.; Reischl, M.; Mikut, R. & Stegmaier, J.
% XPIWIT - An XML Pipeline Wrapper for the Insight Toolkit,
% Bioinformatics, 2016, 32, 315-317.
%
% Stegmaier, J.; Otte, J. C.; Kobitski, A.; Bartschat, A.; Garcia, A.; Nienhaus, G. U.; Strähle, U. & Mikut, R.
% Fast Segmentation of Stained Nuclei in Terabyte-Scale, Time Resolved 3D Microscopy Image Stacks,
% PLoS ONE, 2014, 9, e90036
%
%%

%% the key event handler
function keyReleaseEventHandler(~,evt)
    global settings;

    settings.xLim = get(gca, 'XLim');
    settings.yLim = get(gca, 'YLim');

    %% switch between the images of the loaded series
    if (strcmp(evt.Key, 'rightarrow'))
        settings.currentSlice = min(size(settings.imageChannel1,3), settings.currentSlice+1);
        updateVisualization;
    elseif (strcmp(evt.Key, 'leftarrow'))
        settings.currentSlice = max(1, settings.currentSlice-1);
        updateVisualization;
        %% not implemented yet, maybe use for contrast or scrolling
    elseif (strcmp(evt.Character, '+') || strcmp(evt.Key, 'uparrow'))
        if (settings.thresholdMode == 1)
            settings.showDetections = false;
            settings.gamma(settings.thresholdChannel) = min(5, settings.gamma(settings.thresholdChannel)+0.1);
        end
        if (settings.thresholdMode == 2)
            settings.globalThreshold(settings.thresholdChannel) = settings.globalThreshold(settings.thresholdChannel) + settings.globalThresholdStep;
        end
        if (settings.thresholdMode == 3)
            settings.snrThreshold(settings.thresholdChannel) = settings.snrThreshold(settings.thresholdChannel) + 0.05;
        end
        if (settings.thresholdMode == 4)
            settings.fuseRedundantSeeds = settings.fuseRedundantSeeds + 1;
        end

        %% filter the seed points based on the current SNR threshold
        if (settings.thresholdMode > 1)
            settings.showDetections = true;
            PerformSeedFiltering;
        end
        updateVisualization;
    elseif (strcmp(evt.Character, '-') || strcmp(evt.Key, 'downarrow'))
        if (settings.thresholdMode == 1)
            settings.showDetections = false;
            settings.gamma(settings.thresholdChannel) = max(0, settings.gamma(settings.thresholdChannel) - 0.1);
        end
        if (settings.thresholdMode == 2)
            settings.globalThreshold(settings.thresholdChannel) = max(0, settings.globalThreshold(settings.thresholdChannel) - settings.globalThresholdStep);
        end
        if (settings.thresholdMode == 3)
            settings.snrThreshold(settings.thresholdChannel) = max(1, settings.snrThreshold(settings.thresholdChannel) - 0.05);
        end
        if (settings.thresholdMode == 4)
            settings.fuseRedundantSeeds = max(0, settings.fuseRedundantSeeds - 1);
        end

        %% filter the seed points based on the current SNR threshold
        if (settings.thresholdMode > 1)
            settings.showDetections = true;
            PerformSeedFiltering;
        end
        updateVisualization;
        %% save dialog
    elseif (strcmp(evt.Character, 'a'))
        settings.axesEqual = ~settings.axesEqual;
        updateVisualization;
    elseif (strcmp(evt.Character, 'b'))
        if (settings.dirtyFlag == true)
            PerformColocalization;
        end

        settings.showBackgroundDots = ~settings.showBackgroundDots;
        if (settings.showBackgroundDots)
            rng(42);
            GenerateBackgroundDots;
        end
        updateVisualization;
    elseif (strcmp(evt.Character, 'e'))
        ExportResults;
        msgbox(['Results successfully saved to ' settings.outputFolder], 'Finished saving results ...');
    elseif (strcmp(evt.Character, 'l'))
        settings.showScaleBar = ~settings.showScaleBar;

        if (settings.showScaleBar == true)

            %% ask for voxel resulution
            prompt = {'ScaleBar Length (mu):','ScaleBar Height (px):', 'ScaleBar Color (r, g, b):'};
            dlg_title = 'Provide ScaleBar Settings';
            num_lines = 1;

            if (~isfield(settings, 'scaleBar'))
                defaultans = {'10','10','[1.0, 1.0, 1.0]'};
            else
                defaultans = {num2str(settings.scaleBarLengthMicrons), ...
                    num2str(settings.scaleBarHeight), ...
                    ['[' num2str(settings.scaleBarColor(1)) ',' num2str(settings.scaleBarColor(2)) ',' num2str(settings.scaleBarColor(3)) ']']};
            end

            answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
            
            if (isempty(answer))
                settings.showScaleBar = false;
                return;
            end
            
            settings.scaleBarLengthMicrons = str2double(answer{1});
            settings.scaleBarLengthPixels = str2double(answer{1}) / settings.physicalSpacingXY;
            settings.scaleBarHeight = str2double(answer{2});
            settings.scaleBarColor = eval(answer{3});
            %settings.showScaleBarText = str2double(answer{4});
            settings.scaleBarPosition = ginput(1);
        end

        updateVisualization;

    elseif (strcmp(evt.Character, 'm'))
        settings.maximumProjectionMode = ~settings.maximumProjectionMode;
        updateVisualization;
    elseif (strcmp(evt.Character, 't'))
        settings.thresholdMode = mod(settings.thresholdMode, 4) + 1;
        updateVisualization;
    elseif (strcmp(evt.Character, 'i'))
        settings.showIDs = ~settings.showIDs;

        if (settings.showIDs == true)
            settings.idLabelHandle = text(0,0,'Test');
        else
            delete(settings.idLabelHandle);
            settings.idLabelHandle = [];
        end

        updateVisualization;
    elseif (strcmp(evt.Character, 'c'))
        settings.showColocalization = ~settings.showColocalization;
        if (settings.dirtyFlag == true)
            PerformColocalization;
        end
        updateVisualization;
    elseif (strcmp(evt.Character, 'r'))
        settings.gamma = [1.0, 1.0];
        settings.globalThreshold = [0.0, 0.0];
        settings.snrThreshold = [1.0, 1.0];
        settings.fuseRedundantSeeds = 0;
        
        %% filter the seed points based on the current SNR threshold
        PerformSeedFiltering;
        updateVisualization;
    elseif (strcmp(evt.Character, 'y'))
        settings.colormapIndex = max(1, settings.colormapIndex-1);
        updateVisualization;
    elseif (strcmp(evt.Character, 'x'))
        settings.colormapIndex = min(length(settings.colormapStrings), settings.colormapIndex+1);
        updateVisualization;
    elseif (strcmp(evt.Character, 'd'))
        settings.showDetections = ~settings.showDetections;
        updateVisualization;
    elseif (strcmp(evt.Character, 'o'))
        settings.xLim = [1, size(settings.imageChannel1,1)];
        settings.yLim = [1, size(settings.imageChannel1,2)];
        updateVisualization;
    elseif (strcmp(evt.Character, 'p'))
        showResultsOverview;
    elseif (strcmp(evt.Character, 's'))

        %% perform the colocalization if the threshold was changed
        if (settings.dirtyFlag == true)
            PerformColocalization;
            updateVisualization;
        end

        if (~isfield(settings, 'backgroundDots'))
            GenerateBackgroundDots;
            updateVisualization;
        end

        %         index1 = settings.meanIntensityIndex;
        %         index2 = settings.meanIntensityIndex2;
        index1 = settings.integratedIntensityIndex;
        index2 = settings.integratedIntensityIndex2;

        maxIntensity1 = max([max(settings.colocalizations1(:,index1)), ...
            max(settings.colocalizations2(:,index2)), ... %% index2, as the second intensities for the second channel detections correspond to channel 1
            max(settings.unColocalized1(:,index1)), ...
            max(settings.unColocalized2(:,index2))]); %% index2, as the second intensities for the second channel detections correspond to channel 1

        maxIntensity2 = max([max(settings.colocalizations1(:,index2)), ...
            max(settings.colocalizations2(:,index1)), ...
            max(settings.unColocalized1(:,index2)), ...
            max(settings.unColocalized2(:,index1))]);

        if (isfield(settings, 'backgroundDots') && ~isempty(settings.backgroundDots))
            maxIntensity1 = max(maxIntensity1, max(settings.backgroundDots(:,index1)));
            maxIntensity2 = max(maxIntensity2, max(settings.backgroundDots(:,index2)));
        end
        maxIntensity = max(maxIntensity1, maxIntensity2);

        figure;
        subplot(2,2,1);
        scatter(settings.colocalizations1(:,index1), settings.colocalizations2(:,index1));
        title('Colocalized Detections');
        xlabel('Integrated Intensity (Ch1)');
        ylabel('Integrated Intensity (Ch2)');
        axis([0,maxIntensity, 0, maxIntensity]);

        subplot(2,2,2);
        scatter(settings.unColocalized1(:,index1), settings.unColocalized1(:,index2));
        title('Non-Colocalized Detections (Ch1)');
        xlabel('Integrated Intensity (Ch1)');
        ylabel('Integrated Intensity (Ch2)');
        axis([0,maxIntensity, 0, maxIntensity]);

        subplot(2,2,3);
        scatter(settings.unColocalized2(:,index2), settings.unColocalized2(:,index1));
        title('Non-Colocalized Detections (Ch2)');
        xlabel('Integrated Intensity (Ch1)');
        ylabel('Integrated Intensity (Ch2)');
        axis([0,maxIntensity, 0, maxIntensity]);

        subplot(2,2,4);
        if (isfield(settings, 'backgroundDots') && ~isempty(settings.backgroundDots))
            scatter(settings.backgroundDots(:,index1), settings.backgroundDots(:,index2));
            title('Background Detections');
            xlabel('Integrated Intensity (Ch1)');
            ylabel('Integrated Intensity (Ch2)');
            axis([0,maxIntensity, 0, maxIntensity]);
        end
    elseif (strcmp(evt.Character, 'g'))
        %% show the help dialog
        PerformThresholdGridSearchAndColocalization;    
    elseif (strcmp(evt.Character, 'u'))
        PerformSpotReestimation;
    elseif (strcmp(evt.Character, 'h'))
        %% show the help dialog
        showHelp;
    elseif (strcmp(evt.Character, '1'))
        settings.currentChannel = 1;
        settings.thresholdChannel = 1;
        updateVisualization;
    elseif (strcmp(evt.Character, '2'))
        settings.currentChannel = 2;
        settings.thresholdChannel = 2;
        updateVisualization;
    elseif (strcmp(evt.Character, '3'))
        settings.currentChannel = 3;
        settings.thresholdChannel = [1,2];
        updateVisualization;
    elseif (strcmp(evt.Character, '4'))

    end
end