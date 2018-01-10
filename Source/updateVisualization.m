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

%% get the global settings
global settings;

%% ensure current slice is valid
settings.currentSlice = min(max(1, settings.currentSlice), size(settings.imageChannel1,3));

%% filter the detections
%% ...
settings.colormap = settings.colormapStrings{settings.colormapIndex};
figure(settings.mainFigure);
clf;
set(settings.mainFigure, 'Color', 'black');
set(gca, 'Units', 'normalized', 'Position', [0,0,1,1]);
% colordef black;
% set(gcf, 'Color', 'black');
% set(gca, 'Color', 'black');

if (settings.maximumProjectionMode == true)
    set(settings.mainFigure, 'Name', ['Maximum Projection (Channel ' num2str(settings.currentChannel) ')']);
    
    %% plot the background images
    redChannel = imadjust(settings.imageChannel1MaxProj, [settings.minIntensity, settings.maxIntensity], [], settings.gamma(1));
    greenChannel = imadjust(settings.imageChannel2MaxProj, [settings.minIntensity, settings.maxIntensity], [], settings.gamma(2));
    if (settings.currentChannel == 1)
        imagesc(cat(3, redChannel, redChannel, redChannel)); colormap(settings.colormap); hold on;
    elseif (settings.currentChannel == 2)
        imagesc(cat(3,greenChannel, greenChannel, greenChannel)); colormap(settings.colormap); hold on;
    elseif (settings.currentChannel == 3)
        imagesc(cat(3, redChannel, greenChannel, zeros(size(settings.imageChannel2MaxProj)))); colormap gray; hold on;
    end
    
    %% plot detections of the red channel
    if (~isempty(settings.seedPoints1Filtered) && settings.showDetections == true && (settings.currentChannel == 1 || settings.currentChannel == 3))
       
        %% identify the colocalized ones, such that only the non-colocalized are plotted in red
        if (isfield(settings, 'colocalizations1') && ~isempty(settings.colocalizations1) && settings.showColocalization == true)
            validIndices = find(~ismember(settings.seedPoints1Filtered(:,1), settings.colocalizations1(:,1)));
            plot(settings.seedPoints1Filtered(validIndices,3), settings.seedPoints1Filtered(validIndices,4), 'or');
        else
            plot(settings.seedPoints1Filtered(:,3), settings.seedPoints1Filtered(:,4), 'or');
        end            
    end

    %% plot detections of the green channel
    if (~isempty(settings.seedPoints2Filtered) && settings.showDetections == true && (settings.currentChannel == 2 || settings.currentChannel == 3))
        %% identify the colocalized ones, such that only the non-colocalized are plotted in green
        if (isfield(settings, 'colocalizations2') && ~isempty(settings.colocalizations2) && settings.showColocalization == true)
            validIndices = find(~ismember(settings.seedPoints2Filtered(:,1), settings.colocalizations2(:,1)));
            plot(settings.seedPoints2Filtered(validIndices,3), settings.seedPoints2Filtered(validIndices,4), 'og');
        else
            plot(settings.seedPoints2Filtered(:,3), settings.seedPoints2Filtered(:,4), 'og');
        end
    end
    
    %% plot colocalized detections
    if (settings.showColocalization == true && isfield(settings, 'colocalizations1') && ~isempty(settings.colocalizations1))
        %plot(settings.colocalizations1(:,3), settings.colocalizations1(:,4), 'xm');
%         plot(settings.colocalizations1(:,3), settings.colocalizations1(:,4), 'oy');
%         plot(settings.colocalizations2(:,3), settings.colocalizations2(:,4), 'oy');
        plot(0.5*(settings.colocalizations1(:,3)+settings.colocalizations2(:,3)), 0.5*(settings.colocalizations1(:,4) + settings.colocalizations2(:,4)), 'oy');
    end
    
    if (isfield(settings, 'backgroundDots') && settings.showBackgroundDots == true)
        plot(settings.backgroundDots(:,3), settings.backgroundDots(:,4), '*m');
    end
    
    hold off;
else
    set(settings.mainFigure, 'Name', ['Current Slice: ' num2str(settings.currentSlice) '/' num2str(size(settings.imageChannel2,3)) ' (Channel ' num2str(settings.currentChannel) ')']);

    %% plot the background images
    redChannel = imadjust(settings.imageChannel1(:,:,settings.currentSlice), [settings.minIntensity, settings.maxIntensity], [], settings.gamma(1));
    greenChannel = imadjust(settings.imageChannel2(:,:,settings.currentSlice), [settings.minIntensity, settings.maxIntensity], [], settings.gamma(2));
    if (settings.currentChannel == 1); colormap gray;
        imagesc(cat(3, redChannel, redChannel, redChannel)); colormap(settings.colormap); hold on;    
    elseif (settings.currentChannel == 2)
        imagesc(cat(3, greenChannel, greenChannel, greenChannel)); colormap(settings.colormap); hold on;
    elseif (settings.currentChannel == 3)
        imagesc(cat(3, redChannel, greenChannel, zeros(size(settings.imageChannel2MaxProj)))); colormap(settings.colormap); hold on;
    end
    
    %% plot detections of the red channel
    if (~isempty(settings.seedPoints1Filtered) && settings.showDetections == true && (settings.currentChannel == 1 || settings.currentChannel == 3))
        validIndices = settings.seedPoints1Filtered(:,5)-(settings.seedPoints1Filtered(:,2)) <= settings.currentSlice & ...
                       settings.seedPoints1Filtered(:,5)+(settings.seedPoints1Filtered(:,2)) >= settings.currentSlice;
                   
        if (isfield(settings, 'colocalizations1') && ~isempty(settings.colocalizations1) && settings.showColocalization == true)
             validIndices = validIndices & ~ismember(settings.seedPoints1Filtered(:,1), settings.colocalizations1(:,1));
        end
                   
        plot(settings.seedPoints1Filtered(validIndices,3), settings.seedPoints1Filtered(validIndices,4), 'or');

        validIndices = settings.seedPoints1Filtered(:,5) == settings.currentSlice;
        plot(settings.seedPoints1Filtered(validIndices,3), settings.seedPoints1Filtered(validIndices,4), '.r');
    end

    %% plot detections of the green channel
    if (~isempty(settings.seedPoints2Filtered) && settings.showDetections == true && (settings.currentChannel == 2 || settings.currentChannel == 3))
        validIndices = settings.seedPoints2Filtered(:,5)-(settings.seedPoints2Filtered(:,2)) <= settings.currentSlice & ...
                       settings.seedPoints2Filtered(:,5)+(settings.seedPoints2Filtered(:,2)) >= settings.currentSlice;
                   
        if (isfield(settings, 'colocalizations2') && ~isempty(settings.colocalizations2) && settings.showColocalization == true)
             validIndices = validIndices & ~ismember(settings.seedPoints2Filtered(:,1), settings.colocalizations2(:,1));
        end
                   
        plot(settings.seedPoints2Filtered(validIndices,3), settings.seedPoints2Filtered(validIndices,4), 'og');

        validIndices = settings.seedPoints2Filtered(:,5) == settings.currentSlice;
        plot(settings.seedPoints2Filtered(validIndices,3), settings.seedPoints2Filtered(validIndices,4), '.g');
    end
    
    %% plot colocalized detections
    if (settings.showColocalization == true && isfield(settings, 'colocalizations1') && ~isempty(settings.colocalizations1))
        validIndices1 = settings.colocalizations1(:,5)-(settings.colocalizations1(:,2)) <= settings.currentSlice & ...
                        settings.colocalizations1(:,5)+(settings.colocalizations1(:,2)) >= settings.currentSlice;
        validIndices2 = settings.colocalizations2(:,5)-(settings.colocalizations2(:,2)) <= settings.currentSlice & ...
                        settings.colocalizations2(:,5)+(settings.colocalizations2(:,2)) >= settings.currentSlice;
        
       plot(settings.colocalizations1(validIndices1,3), settings.colocalizations1(validIndices1,4), 'oy');
       plot(settings.colocalizations2(validIndices2,3), settings.colocalizations2(validIndices2,4), 'oy');
    end
    
    if (isfield(settings, 'backgroundDots') && settings.showBackgroundDots == true)
        validIndices = (settings.backgroundDots(:,5) == settings.currentSlice);
        plot(settings.backgroundDots(validIndices,3), settings.backgroundDots(validIndices,4), '*m');
    end
end

textColors = {'white', 'red'};
text('String', ['Gamma: ' num2str(settings.gamma(1)) ', ' num2str(settings.gamma(2))], 'FontSize', settings.fontSize, 'Color', textColors{(settings.thresholdMode == 1) + 1}, 'Units', 'normalized', 'Position', [0.01 0.98], 'Background', 'black');
text('String', ['Global Threshold: ' num2str(settings.globalThreshold(1)) ', ' num2str(settings.globalThreshold(2))], 'FontSize', settings.fontSize, 'Color', textColors{(settings.thresholdMode == 2) + 1}, 'Units', 'normalized', 'Position', [0.01 0.94], 'Background', 'black');
text('String', ['SNR Threshold: ' num2str(settings.snrThreshold(1)) ', ' num2str(settings.snrThreshold(2))], 'FontSize', settings.fontSize, 'Color', textColors{(settings.thresholdMode == 3) + 1}, 'Units', 'normalized', 'Position', [0.01 0.90], 'Background', 'black');
text('String', ['Fusion Radius: ' num2str(settings.fuseRedundantSeeds * settings.physicalSpacingXY)], 'FontSize', settings.fontSize, 'Color', textColors{(settings.thresholdMode == 4) + 1}, 'Units', 'normalized', 'Position', [0.01 0.86], 'Background', 'black');

if (settings.showScaleBar)
    if (isfield(settings, 'scaleBar') && ishandle(settings.scaleBar))
        delete(settings.scaleBar);
    end
%     if (isfield(settings, 'scaleBarText') && ishandle(settings.scaleBarText))
%         delete(settings.scaleBarText);
%     end
    settings.scaleBar = rectangle('Position',[settings.scaleBarPosition(1)-settings.scaleBarLengthPixels, settings.scaleBarPosition(2)-settings.scaleBarHeight, settings.scaleBarLengthPixels, settings.scaleBarHeight],'FaceColor', settings.scaleBarColor);
%     if (settings.showScaleBarText == true)
%        settings.scaleBarText = text('String', [num2str(settings.scaleBarLengthMicrons) ' µm'], 'FontSize', settings.fontSize, 'Color', settings.scaleBarColor, 'Position', [settings.scaleBarPosition(1), settings.scaleBarPosition(2)]);
%        settings.scaleBarText.Position = [settings.scaleBarPosition(1)-(settings.scaleBarLengthPixels)-(settings.scaleBarLengthPixels/2 - settings.scaleBarText.Extent(3)/2), settings.scaleBarPosition(2) + settings.scaleBarHeight + 1, 0];
%     end
end

if (settings.axesEqual == true)
    axis equal;
end
axis off;

set(gca, 'XLim', settings.xLim);
set(gca, 'YLim', settings.yLim);
