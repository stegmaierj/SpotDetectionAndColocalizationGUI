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
 
function mouseMove(~, ~)
    global settings;
    currentPosition = get(gca, 'currentpoint');
    currentPosition = round([currentPosition(1,1), currentPosition(1,2)]);

    if (settings.showIDs == true)

        if (isempty(settings.idLabelHandle) || ~isvalid(settings.idLabelHandle))
            settings.idLabelHandle = text(0,0,'');
        end

        [channel1Index, channel1Distance] = knnsearch(settings.currentKDTree1, currentPosition, 'K', 1);
        [channel2Index, channel2Distance] = knnsearch(settings.currentKDTree2, currentPosition, 'K', 1);

        if (isempty(channel1Distance))
            channel1Distance = inf;
        end
        if (isempty(channel2Distance))
            channel2Distance = inf;
        end

        if ((channel1Distance < channel2Distance && settings.currentChannel == 3) || settings.currentChannel == 1)
            set(settings.idLabelHandle, 'Position', [settings.seedPoints1Filtered(channel1Index, 3)+0.5, settings.seedPoints1Filtered(channel1Index, 4), 0]);
            set(settings.idLabelHandle, 'String', ['ID = ' num2str(round(settings.seedPoints1Filtered(channel1Index, 1))) ', Pos = ' num2str(round(settings.seedPoints1Filtered(channel1Index, 3:5))) ', Radius = ' num2str(settings.seedPoints1Filtered(channel1Index, 2)*settings.physicalSpacingXY) ', Int=' num2str(settings.seedPoints1Filtered(channel1Index, settings.meanIntensityIndex))]);
            set(settings.idLabelHandle, 'Color', [1,0,0]);
        end
        
        if ((channel1Distance >= channel2Distance && settings.currentChannel == 3) || settings.currentChannel == 2)
            set(settings.idLabelHandle, 'Position', [settings.seedPoints2Filtered(channel2Index, 3)+0.5, settings.seedPoints2Filtered(channel2Index, 4), 0]);
            set(settings.idLabelHandle, 'String', ['ID = ' num2str(settings.seedPoints2Filtered(channel2Index, 1)) ', Pos = ' num2str(round(settings.seedPoints2Filtered(channel2Index, 3:5))) ', Radius = ' num2str(settings.seedPoints2Filtered(channel2Index, 2)*settings.physicalSpacingXY) ', Int=' num2str(settings.seedPoints2Filtered(channel2Index, settings.meanIntensityIndex))]);
            set(settings.idLabelHandle, 'Color', [0,1,0]);
        end
    end
end