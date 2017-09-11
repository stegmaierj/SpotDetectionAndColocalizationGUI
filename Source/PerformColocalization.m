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

%% get the global settings variable
global settings;

h = waitbar(0,'Performing colocalization for current threshold ...');

%% generate the kd trees for the current threshold
channel1KDTree = KDTreeSearcher([settings.seedPoints1Filtered(:,3)*settings.physicalSpacingXY, settings.seedPoints1Filtered(:,4)*settings.physicalSpacingXY, settings.seedPoints1Filtered(:,5)*settings.physicalSpacingZ * settings.axialColocalizationFactor]);
channel2KDTree = KDTreeSearcher([settings.seedPoints2Filtered(:,3)*settings.physicalSpacingXY, settings.seedPoints2Filtered(:,4)*settings.physicalSpacingXY, settings.seedPoints2Filtered(:,5)*settings.physicalSpacingZ * settings.axialColocalizationFactor]);

%% perform colocalization
settings.colocalizations1 = [];
settings.colocalizations2 = [];
for i=1:size(settings.seedPoints1Filtered,1)
    
    %% get the scale of the current seed point and search a matching partner in channel 2
    currentScale = settings.seedPoints1Filtered(i,2) * settings.physicalSpacingXY;
    [index2, distance2] = knnsearch(channel2KDTree, settings.seedPoints1Filtered(i,3:5) .* [settings.physicalSpacingXY, settings.physicalSpacingXY, settings.physicalSpacingZ*settings.axialColocalizationFactor], 'K', 1);
    [index1, distance1] = knnsearch(channel1KDTree, settings.seedPoints2Filtered(index2,3:5) .* [settings.physicalSpacingXY, settings.physicalSpacingXY, settings.physicalSpacingZ*settings.axialColocalizationFactor], 'K', 1);
    radius1 = settings.seedPoints1Filtered(index1,2) * settings.physicalSpacingXY;
    radius2 = settings.seedPoints2Filtered(index2,2) * settings.physicalSpacingXY;
    
    %% switch the distance criterion used for counting a colocalization
    if (settings.colocalizationCriterion < 0)
        %% if smaller than zero, bounding sphere intersection is used
        maxDistance = (radius1+radius2);
    else
        %% otherwise the provided distance in pixel is the maximum allowed centroid distance
        maxDistance = settings.colocalizationCriterion;
    end
    
    %% only add detection if there was a single unambiguous match
    if (index1 == i && distance1 <= maxDistance)
       ratio1 = settings.seedPoints1Filtered(i,settings.meanIntensityIndex) / settings.seedPoints2Filtered(index2,settings.meanIntensityIndex);
       ratio2 = settings.seedPoints2Filtered(index2,settings.meanIntensityIndex) / settings.seedPoints1Filtered(i,settings.meanIntensityIndex);
       settings.colocalizations1 = [settings.colocalizations1; settings.seedPoints1Filtered(i,:), distance1, radius1, ratio1];
       settings.colocalizations2 = [settings.colocalizations2; settings.seedPoints2Filtered(index2,:), distance2, radius2, ratio2];
    end
    
    %% show status
    if (mod(i,100) == 0 || i == size(settings.seedPoints1Filtered,1))
        waitbar(i / size(settings.seedPoints1Filtered,1));
    end
end

%% compute the non-colocalized seed points after filtering
settings.unColocalized1 = settings.seedPoints1Filtered(~ismember(settings.seedPoints1Filtered(:,1), settings.colocalizations1),:);
settings.unColocalized2 = settings.seedPoints2Filtered(~ismember(settings.seedPoints2Filtered(:,1), settings.colocalizations2),:);

%% close the progress bar
close(h);
settings.dirtyFlag = false;