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

global settings;

%% perform local adaptive threshold for all seed points of image 1
settings.seedPoints1(:,end+1) = 0;
settings.meanIntensityIndex = size(settings.seedPoints1,2);
settings.seedPoints1(:,end+1) = 0;
settings.snrRatioIndex = size(settings.seedPoints1,2);
settings.seedPoints1(:,end+1) = 0;
settings.integratedIntensityIndex = size(settings.seedPoints1,2);
settings.seedPoints1(:,end+1) = 0;
settings.meanIntensityIndex2 = size(settings.seedPoints1,2);
settings.seedPoints1(:,end+1) = 0;
settings.snrRatioIndex2 = size(settings.seedPoints1,2);
settings.seedPoints1(:,end+1) = 0;
settings.integratedIntensityIndex2 = size(settings.seedPoints1,2);
currentDistances = [];
for i=1:size(settings.seedPoints1,1)
    
    %% get the current location and calculate the radii
    currentLocation = round(settings.seedPoints1(i,3:5));
    innerRadius = settings.radiusMultiplier*round(settings.seedPoints1(i,2));
    outerRadius = round(settings.radiusMultiplier*innerRadius);
    
    %% calculate the inner and outer ranges
    rangeX = max(1, currentLocation(1)-innerRadius):min(size(settings.imageChannel1,2), currentLocation(1)+innerRadius);
    rangeY = max(1, currentLocation(2)-innerRadius):min(size(settings.imageChannel1,1), currentLocation(2)+innerRadius);
    rangeZ = max(1, currentLocation(3)-round(innerRadius/settings.zscale)):min(size(settings.imageChannel1,3), currentLocation(3)+round(innerRadius/settings.zscale));
        
    rangeXBG = max(1, currentLocation(1)-outerRadius):min(size(settings.imageChannel1,2), currentLocation(1)+outerRadius);
    rangeYBG = max(1, currentLocation(2)-outerRadius):min(size(settings.imageChannel1,1), currentLocation(2)+outerRadius);
    rangeZBG = max(1, currentLocation(3)-round(outerRadius/settings.zscale)):min(size(settings.imageChannel1,3), currentLocation(3)+round(outerRadius/settings.zscale));
    
    %% extract intensity properties of the channel where the seeds were detected
    innerSnippet = settings.imageChannel1(rangeY, rangeX, rangeZ);
    outerSnippet = settings.imageChannel1(rangeYBG, rangeXBG, rangeZBG);
    innerSum = sum(innerSnippet(:));
    outerSum = sum(outerSnippet(:)) - innerSum;
    innerMean = innerSum / length(innerSnippet(:));
    outerMean = outerSum / (length(outerSnippet(:)) - length(innerSnippet(:)));
    currentRatio = innerMean / outerMean;
    settings.seedPoints1(i,settings.meanIntensityIndex) = innerMean;
    settings.seedPoints1(i,settings.snrRatioIndex) = currentRatio;
    settings.seedPoints1(i,settings.integratedIntensityIndex) = innerSum;
    
    %% extract intensity properties of the second channel not used to detect the current seeds
    innerSnippet = settings.imageChannel2(rangeY, rangeX, rangeZ);
    outerSnippet = settings.imageChannel2(rangeYBG, rangeXBG, rangeZBG);
    innerSum = sum(innerSnippet(:));
    outerSum = sum(outerSnippet(:)) - innerSum;
    innerMean = innerSum / length(innerSnippet(:));
    outerMean = outerSum / (length(outerSnippet(:)) - length(innerSnippet(:)));
    currentRatio = innerMean / outerMean;
    settings.seedPoints1(i,settings.meanIntensityIndex2) = innerMean;
    settings.seedPoints1(i,settings.snrRatioIndex2) = currentRatio;
    settings.seedPoints1(i,settings.integratedIntensityIndex2) = innerSum;
    
    %% re-estimate the weighted centroid based on the underlying intensity
    if (settings.weightedCentroid == true)
        centroid = zeros(3,1);
        intensitySum = 0;
        for j=rangeX
            for k=rangeY
                for l=rangeZ
                    if (norm([j,k,l*settings.zscale]) <= innerRadius)
                        intensitySum = intensitySum + settings.imageChannel1(k, j, l);
                        centroid = centroid + settings.imageChannel1(k, j, l) * [j,k,l]';
                    end
                end
            end
        end
        if (intensitySum > 0)
            centroid = centroid / intensitySum;
        else
            centroid = currentLocation';
        end    
        currentDistances = [currentDistances; norm(currentLocation' - centroid)];
        settings.seedPoints1(i,3:5) = centroid;
    end
end

%% perform local adaptive threshold for all seed points of image 2
settings.seedPoints2(:,end+1) = 0;
settings.seedPoints2(:,end+1) = 0;
settings.seedPoints2(:,end+1) = 0;
settings.seedPoints2(:,end+1) = 0;
settings.seedPoints2(:,end+1) = 0;
settings.seedPoints2(:,end+1) = 0;
for i=1:size(settings.seedPoints2,1)
    
    %% get the current location and calculate the radii
    currentLocation = round(settings.seedPoints2(i,3:5));
    innerRadius = settings.radiusMultiplier*round(settings.seedPoints2(i,2));
    outerRadius = round(settings.radiusMultiplier*innerRadius);
    
    %% calculate the inner and outer ranges
    rangeX = max(1, currentLocation(1)-innerRadius):min(size(settings.imageChannel2,2), currentLocation(1)+innerRadius);
    rangeY = max(1, currentLocation(2)-innerRadius):min(size(settings.imageChannel2,1), currentLocation(2)+innerRadius);
    rangeZ = max(1, currentLocation(3)-round(innerRadius/settings.zscale)):min(size(settings.imageChannel2,3), currentLocation(3)+round(innerRadius/settings.zscale));
    rangeXBG = max(1, currentLocation(1)-outerRadius):min(size(settings.imageChannel2,2), currentLocation(1)+outerRadius);
    rangeYBG = max(1, currentLocation(2)-outerRadius):min(size(settings.imageChannel2,1), currentLocation(2)+outerRadius);
    rangeZBG = max(1, currentLocation(3)-round(outerRadius/settings.zscale)):min(size(settings.imageChannel2,3), currentLocation(3)+round(outerRadius/settings.zscale));

    %% extract intensity properties of the channel where the seeds were detected
    innerSnippet = settings.imageChannel2(rangeY, rangeX, rangeZ);
    outerSnippet = settings.imageChannel2(rangeYBG, rangeXBG, rangeZBG);
    innerSum = sum(innerSnippet(:));
    outerSum = sum(outerSnippet(:)) - innerSum;
    innerMean = innerSum / length(innerSnippet(:));
    outerMean = outerSum / (length(outerSnippet(:)) - length(innerSnippet(:)));
    currentRatio = innerMean / outerMean;
    settings.seedPoints2(i,settings.meanIntensityIndex) = innerMean;
    settings.seedPoints2(i,settings.snrRatioIndex) = currentRatio;
    settings.seedPoints2(i,settings.integratedIntensityIndex) = innerSum;
    
    %% extract intensity properties of the second channel not used to detect the current seeds
    innerSnippet = settings.imageChannel1(rangeY, rangeX, rangeZ);
    outerSnippet = settings.imageChannel1(rangeYBG, rangeXBG, rangeZBG);
    innerSum = sum(innerSnippet(:));
    outerSum = sum(outerSnippet(:)) - innerSum;
    innerMean = innerSum / length(innerSnippet(:));
    outerMean = outerSum / (length(outerSnippet(:)) - length(innerSnippet(:)));
    currentRatio = innerMean / outerMean;
    settings.seedPoints2(i,settings.meanIntensityIndex2) = innerMean;
    settings.seedPoints2(i,settings.snrRatioIndex2) = currentRatio;
    settings.seedPoints2(i,settings.integratedIntensityIndex2) = innerSum;
    
    %% re-estimate the weighted centroid based on the underlying intensity
    if (settings.weightedCentroid == true)
        centroid = zeros(3,1);
        intensitySum = 0;
        for j=rangeX
            for k=rangeY
                for l=rangeZ
                    if (norm([j,k,l*settings.zscale]) <= innerRadius)
                        intensitySum = intensitySum + settings.imageChannel2(k, j, l);
                        centroid = centroid + settings.imageChannel2(k, j, l) * [j,k,l]';
                    end
                end
            end
        end
        if (intensitySum > 0)
            centroid = centroid / intensitySum;
        else
            centroid = currentLocation';
        end    
        settings.seedPoints2(i,3:5) = centroid;
    end
end

PerformSeedFiltering;