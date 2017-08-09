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

%% perform the colocalization if the threshold was changed
if (settings.dirtyFlag == true)
    PerformColocalization;
    updateVisualization;
end

%% identify the non-colocalized seed points
unColocalized1 = settings.seedPoints1Filtered(~ismember(settings.seedPoints1Filtered(:,1), settings.colocalizations1),:);
unColocalized2 = settings.seedPoints2Filtered(~ismember(settings.seedPoints2Filtered(:,1), settings.colocalizations2),:);

helpText = {sprintf('------------------------ Files ------------------------'), ...
            sprintf('File Channel 1: %s', settings.file1), ...
            sprintf('File Channel 2: %s\n', settings.file2), ...
            sprintf('---------------------- Parameters ---------------------'), ...
            sprintf('Gamma: %f, %f', settings.gamma(1), settings.gamma(2)), ...
            sprintf('Global Threshold: %f, %f', settings.globalThreshold(1), settings.globalThreshold(2)), ...
            sprintf('SNR Threshold: %f, %f\n', settings.snrThreshold(1), settings.snrThreshold(2)), ...
            sprintf('----------------------- Results -----------------------'), ...
            sprintf('Total Detections Channel 1: %i', size(settings.seedPoints1,1)), ...
            sprintf('Total Detections Channel 2: %i\n', size(settings.seedPoints2,1)), ...
            sprintf('Thresholded Detections Channel 1: %i', size(settings.seedPoints1Filtered,1)), ...
            sprintf('Thresholded Detections Channel 2: %i\n', size(settings.seedPoints2Filtered,1)), ...
            sprintf('Colocalized Detections Channel 1: %i', size(settings.colocalizations1,1)), ...
            sprintf('Colocalized Detections Channel 2: %i\n', size(settings.colocalizations2,1)), ...
            sprintf('Uncolocalized Detections Channel 1: %i', size(unColocalized1,1)), ...
            sprintf('Uncolocalized Detections Channel 2: %i\n', size(unColocalized2,1)), ...
            sprintf('Percentage Colocalized Detections Channel 1: %.2f%%', 100*size(settings.colocalizations1,1)/size(settings.seedPoints1Filtered,1)), ...
            sprintf('Percentage Colocalized Detections Channel 2: %.2f%%\n', 100*size(settings.colocalizations2,1)/size(settings.seedPoints2Filtered,1)), ...
            sprintf('Percentage Uncolocalized Detections Channel 1: %.2f%%', 100*size(unColocalized1,1)/size(settings.seedPoints1Filtered,1)), ...
            sprintf('Percentage Uncolocalized Detections Channel 2: %.2f%%', 100*size(unColocalized2,1)/size(settings.seedPoints2Filtered,1))};

msgbox(helpText, 'Colocalization Results Overview');