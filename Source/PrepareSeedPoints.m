global settings;

%% adjust seed points 1
settings.seedPoints1(:,3) = settings.seedPoints1(:,3)+settings.offset;
settings.seedPoints1(:,4) = settings.seedPoints1(:,4)+settings.offset;
settings.seedPoints1(:,5) = round(settings.seedPoints1(:,5)/settings.zscale)+settings.offset;

%% adjust seed points 2
settings.seedPoints2(:,3) = settings.seedPoints2(:,3)+settings.offset;
settings.seedPoints2(:,4) = settings.seedPoints2(:,4)+settings.offset;
settings.seedPoints2(:,5) = round(settings.seedPoints2(:,5)/settings.zscale)+settings.offset;

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
    currentLocation = settings.seedPoints1(i,3:5);
    innerRadius = round(settings.seedPoints1(i,2)*sqrt(2));
    outerRadius = round(settings.radiusMultiplier*innerRadius);
    
    %% calculate the inner and outer ranges
    rangeX = max(1, currentLocation(1)-innerRadius):min(size(settings.imageChannel1,1), currentLocation(1)+innerRadius);
    rangeY = max(1, currentLocation(2)-innerRadius):min(size(settings.imageChannel1,2), currentLocation(2)+innerRadius);
    rangeZ = max(1, currentLocation(3)-round(innerRadius/settings.zscale)):min(size(settings.imageChannel1,3), currentLocation(3)+round(innerRadius/settings.zscale));
        
    rangeXBG = max(1, currentLocation(1)-outerRadius):min(size(settings.imageChannel1,1), currentLocation(1)+outerRadius);
    rangeYBG = max(1, currentLocation(2)-outerRadius):min(size(settings.imageChannel1,2), currentLocation(2)+outerRadius);
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
                    intensitySum = intensitySum + settings.imageChannel1(k, j, l);
                    centroid = centroid + settings.imageChannel1(k, j, l) * [j,k,l]';
                end
            end
        end
        if (intensitySum > 0)
            centroid = centroid / intensitySum;
        else
            centroid = currentLocation';
        end    
        currentDistances = [currentDistances; norm(currentLocation' - centroid)];
        settings.seedPoints1(i,3:5) = round(centroid);
    end
end

blubb = sum(currentDistances > 1);
mypercentage = 100 * blubb / length(currentDistances);

%% perform local adaptive threshold for all seed points of image 2
settings.seedPoints2(:,end+1) = 0;
settings.seedPoints2(:,end+1) = 0;
settings.seedPoints2(:,end+1) = 0;
settings.seedPoints2(:,end+1) = 0;
settings.seedPoints2(:,end+1) = 0;
settings.seedPoints2(:,end+1) = 0;
for i=1:size(settings.seedPoints2,1)
    
    %% get the current location and calculate the radii
    currentLocation = settings.seedPoints2(i,3:5);
    innerRadius = round(settings.seedPoints2(i,2)*sqrt(2));
    outerRadius = round(settings.radiusMultiplier*innerRadius);
    
    %% calculate the inner and outer ranges
    rangeX = max(1, currentLocation(1)-innerRadius):min(size(settings.imageChannel2,1), currentLocation(1)+innerRadius);
    rangeY = max(1, currentLocation(2)-innerRadius):min(size(settings.imageChannel2,2), currentLocation(2)+innerRadius);
    rangeZ = max(1, currentLocation(3)-round(innerRadius/settings.zscale)):min(size(settings.imageChannel2,3), currentLocation(3)+round(innerRadius/settings.zscale));
    rangeXBG = max(1, currentLocation(1)-outerRadius):min(size(settings.imageChannel2,1), currentLocation(1)+outerRadius);
    rangeYBG = max(1, currentLocation(2)-outerRadius):min(size(settings.imageChannel2,2), currentLocation(2)+outerRadius);
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
                    intensitySum = intensitySum + settings.imageChannel2(k, j, l);
                    centroid = centroid + settings.imageChannel2(k, j, l) * [j,k,l]';
                end
            end
        end
        if (intensitySum > 0)
            centroid = centroid / intensitySum;
        else
            centroid = currentLocation';
        end    
        settings.seedPoints2(i,3:5) = round(centroid);
    end
end