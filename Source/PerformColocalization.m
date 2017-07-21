%%
 % SpotDetectionAndColocalizationGUI.
 % Copyright (C) 2017 J. Stegmaier, A. Cunha, M. Schwarzkopf, H. Choi, N. Pierce
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
 % If you use this application for your work, please cite the repository or 
 % the associated publication on single-molecule analysis.
 %
 %%

%% get the global settings variable
global settings;

h = waitbar(0,'Performing colocalization for current threshold ...');

%% generate the kd trees for the current threshold
channel1KDTree = KDTreeSearcher([settings.seedPoints1Filtered(:,3), settings.seedPoints1Filtered(:,4), settings.seedPoints1Filtered(:,5)*settings.zscale]);
channel2KDTree = KDTreeSearcher([settings.seedPoints2Filtered(:,3), settings.seedPoints2Filtered(:,4), settings.seedPoints2Filtered(:,5)*settings.zscale]);

%% perform colocalization
settings.colocalizations1 = [];
settings.colocalizations2 = [];
for i=1:size(settings.seedPoints1Filtered,1)
    
    %% get the scale of the current seed point and search a matching partner in channel 2
    currentScale = settings.seedPoints1Filtered(i,2)*sqrt(2);
    [index2, distance2] = knnsearch(channel2KDTree, [settings.seedPoints1Filtered(i,3:4), settings.seedPoints1Filtered(i,5)*settings.zscale], 'K', 1);
    [index1, distance1] = knnsearch(channel1KDTree, [settings.seedPoints2Filtered(index2,3:4), settings.seedPoints2Filtered(index2,5)*settings.zscale], 'K', 1);
    radius1 = settings.seedPoints1Filtered(index1,2)*sqrt(2);
    radius2 = settings.seedPoints2Filtered(index2,2)*sqrt(2);
    
    %% only add detection if there was a single unambiguous match
    if (index1 == i && distance1 <= (radius1+radius2))
       ratio1 = settings.seedPoints1Filtered(i,9) / settings.seedPoints2Filtered(index2,9);
       ratio2 = settings.seedPoints2Filtered(index2,9) / settings.seedPoints1Filtered(i,9);
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