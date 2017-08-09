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

%% filter the seed points based on the current SNR threshold
validIndices1 = settings.seedPoints1(:,settings.snrRatioIndex) > settings.snrThreshold(1) & settings.seedPoints1(:,settings.meanIntensityIndex) > settings.globalThreshold(1);
settings.seedPoints1Filtered = settings.seedPoints1(validIndices1, :);

validIndices2 = settings.seedPoints2(:,settings.snrRatioIndex) > settings.snrThreshold(2) & settings.seedPoints2(:,settings.meanIntensityIndex) > settings.globalThreshold(2);
settings.seedPoints2Filtered = settings.seedPoints2(validIndices2, :);
settings.dirtyFlag = true;
settings.showColocalization = false;

settings.currentKDTree1 = KDTreeSearcher(settings.seedPoints1Filtered(:,3:4));
settings.currentKDTree2 = KDTreeSearcher(settings.seedPoints2Filtered(:,3:4));
settings.colocalizations1 = [];
settings.colocalizations2 = [];