
%% compute the average radius of colocalized detections in both channels
averageRadius = round(mean([settings.colocalizations1(:,2); settings.colocalizations2(:,2)] * sqrt(2)));
numBackgroundSamples = size(settings.colocalizations1,1);

%% use all filtered detections
originalDetections = unique([settings.seedPoints1Filtered(:,3:5); settings.seedPoints2Filtered(:,3:5)], 'rows');

%% specify the region of interest based on the convex hull or using a manually drawn roi
choice = questdlg('Would you like to manually draw a region of interest (e.g., if multiple samples are present in the image)', ...
	'Background Detection', ...
	'Yes','No','No');
if (strcmp(choice, 'Yes'))
    fh = figure;
    imagesc(cat(3, imadjust(settings.imageChannel1MaxProj), imadjust(settings.imageChannel2MaxProj), zeros(size(settings.imageChannel1MaxProj))));
    h = imfreehand(gca);
    convexImage = h.createMask;
    close(fh);
    
    detectionsInROI = [];
    for i=1:size(originalDetections,1)
       currentPoint = originalDetections(i,:);
        if (convexImage(currentPoint(2), currentPoint(1)) > 0)
            detectionsInROI = [detectionsInROI; currentPoint];
        end
    end
else
    detectionsInROI = originalDetections;
end

h = waitbar(0,'Generating background detections ...');

%% create the delaunay triangulation
DT = delaunayTriangulation(detectionsInROI);

%% sample the background dots as the incenters of the tetrahedra
backgroundDots = [];
while (size(backgroundDots,1) < numBackgroundSamples)
    
    %% get the current location and calculate the radii
    currentIndex = randperm(size(DT.ConnectivityList, 1), 1);
    currentLocation = round(incenter(DT,currentIndex'));
    
    %% discard samples that are too close to existing detections
    minDistance = inf;
    for i=1:4
        currentNeighbor = DT.Points(DT.ConnectivityList(currentIndex,i), :);
        currentDistance = norm(currentLocation - currentNeighbor);
        
        if (minDistance > currentDistance)
            minDistance = currentDistance;
        end
    end
    if (minDistance < (2*averageRadius*settings.radiusMultiplier))
        continue;
    end    
    
    %% specify the inner and outer radius for intensity estimations
    innerRadius = averageRadius;
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
    
    %% create an entry for the current sample
    currentSample = [size(backgroundDots,1)+1, averageRadius/sqrt(2), currentLocation, max(innerSnippet(:)), 1, 0, innerMean, currentRatio, innerSum];
    
    %% extract intensity properties of the second channel
    innerSnippet = settings.imageChannel2(rangeY, rangeX, rangeZ);
    outerSnippet = settings.imageChannel2(rangeYBG, rangeXBG, rangeZBG);
    innerSum = sum(innerSnippet(:));
    outerSum = sum(outerSnippet(:)) - innerSum;
    innerMean = innerSum / length(innerSnippet(:));
    outerMean = outerSum / (length(outerSnippet(:)) - length(innerSnippet(:)));
    currentRatio = innerMean / outerMean;
    
    currentSample = [currentSample, innerMean, currentRatio, innerSum];
    backgroundDots = [backgroundDots; currentSample];
    
    %% show status
    if (mod(size(backgroundDots,1),25) == 0 || size(backgroundDots,1) == numBackgroundSamples)
        waitbar(size(backgroundDots,1) / numBackgroundSamples);
    end
end

%% close the wait bar
close(h);

%% set the global background dots
settings.backgroundDots = backgroundDots;