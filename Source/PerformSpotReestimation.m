
%% create wait bar
waitBarHandle = waitbar(0, 'Re-estimating centroids');

%% perform local re-estimation of the centroid and radius
validIndices1 = find(settings.seedPoints1(:,settings.snrRatioIndex) > settings.snrThreshold(1) & settings.seedPoints1(:,settings.meanIntensityIndex) > settings.globalThreshold(1));
for i=1:size(settings.seedPoints1Filtered,1)
    
    if (settings.seedPoints1Filtered(i,settings.localReestimationIndex) == 0)
        %% re-estimate using a local search of the maximizing laplacian of gaussian
        [newCentroid, newRadius] = ReestimateGaussianSpot(settings.seedPoints1Filtered(i,3:5), settings.seedPoints1Filtered(i,2), settings.imageChannel1);

%         %% print debug info
%         disp(['Old Centroid: ' num2str(settings.seedPoints1Filtered(i,3:5)), ', Old Radius: ' num2str(settings.seedPoints1Filtered(i,2))]);
%         disp(['New Centroid: ' num2str(newCentroid), ', New Radius: ' num2str(newRadius)]);
        
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

%         %% print debug info
%         disp(['Old Centroid: ' num2str(settings.seedPoints2Filtered(i,3:5)), ', Old Radius: ' num2str(settings.seedPoints2Filtered(i,2))]);
%         disp(['New Centroid: ' num2str(newCentroid), ', New Radius: ' num2str(newRadius)]);
        
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