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

%% if enabled, debug output is shown in the console
debugInfo = false;
 
%% create wait bar
waitBarHandle = waitbar(0, 'Re-estimating centroids');

%% perform local re-estimation of the centroid and radius
validIndices1 = find(settings.seedPoints1(:,settings.snrRatioIndex) > settings.snrThreshold(1) & settings.seedPoints1(:,settings.meanIntensityIndex) > settings.globalThreshold(1));
for i=1:size(settings.seedPoints1Filtered,1)
    
    %% avoid duplicate re-estimations of the same seeds
    if (settings.seedPoints1Filtered(i,settings.localReestimationIndex) == 0)
        
        %% re-estimate using a local search of the maximizing laplacian of gaussian
        [newCentroid, newRadius] = ReestimateGaussianSpot(settings.seedPoints1Filtered(i,3:5), settings.seedPoints1Filtered(i,2), settings.imageChannel1);

        %% print debug info
        if (debugInfo == true)
            disp(['Old Centroid: ' num2str(settings.seedPoints1Filtered(i,3:5)), ', Old Radius: ' num2str(settings.seedPoints1Filtered(i,2))]);
            disp(['New Centroid: ' num2str(newCentroid), ', New Radius: ' num2str(newRadius)]);
        end
        
        %% set the results to the seed points strucure
        settings.seedPoints1(validIndices1(i), 3:5) = newCentroid;
        settings.seedPoints1(validIndices1(i), 2) = newRadius;
        settings.seedPoints1(validIndices1(i), settings.localReestimationIndex) = 1;
        settings.seedPoints1Filtered(i, :) = settings.seedPoints1(validIndices1(i), :);
    end
    
    %% update the wait bar
    if (mod(i, 100) == 0)
        waitbar(0.5 * i / (size(settings.seedPoints1Filtered,1)), waitBarHandle);
    end
end

%% perform local re-estimation of the centroid and radius
validIndices2 = find(settings.seedPoints2(:,settings.snrRatioIndex) > settings.snrThreshold(2) & settings.seedPoints2(:,settings.meanIntensityIndex) > settings.globalThreshold(2));
for i=1:size(settings.seedPoints2Filtered,1)
    
    if (settings.seedPoints2Filtered(i,settings.localReestimationIndex) == 0)
        %% re-estimate using a local search of the maximizing laplacian of gaussian
        [newCentroid, newRadius] = ReestimateGaussianSpot(settings.seedPoints2Filtered(i,3:5), settings.seedPoints2Filtered(i,2), settings.imageChannel2);

        %% print debug info
        if (debugInfo == true)
        	disp(['Old Centroid: ' num2str(settings.seedPoints2Filtered(i,3:5)), ', Old Radius: ' num2str(settings.seedPoints2Filtered(i,2))]);
            disp(['New Centroid: ' num2str(newCentroid), ', New Radius: ' num2str(newRadius)]);
        end

        %% set the results to the seed points strucure
        settings.seedPoints2(validIndices2(i), 3:5) = newCentroid;
        settings.seedPoints2(validIndices2(i), 2) = newRadius;
        settings.seedPoints2(validIndices2(i), settings.localReestimationIndex) = 1;
        settings.seedPoints2Filtered(i, :) = settings.seedPoints2(validIndices2(i), :);
    end
    
    %% update the wait bar
    if (mod(i, 100) == 0)
        waitbar(0.5 + 0.5 * i / (size(settings.seedPoints2Filtered,1)), waitBarHandle);
    end
end

%% remove the wait bar
close(waitBarHandle);
updateVisualization;