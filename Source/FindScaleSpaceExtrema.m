%% function to find scale space extrema in the log scale space
function scaleSpaceExtrema = FindScaleSpaceExtrema(inputImage, scaleSpace, spacing, scaleRange, extremaThreshold)

%% add fft convolution path
%addpath('ThirdParty/convnfft');
addpath('ThirdParty/saveastiff_4.3/');

%% create wait bar
waitBarHandle = waitbar(0, 'Creating LoG Scale Space');

%% identify 
if (extremaThreshold < 0)
    extremaThreshold = mean(inputImage(:));
end

%% initialize the return value
currentId = 1;
scaleSpaceExtrema = zeros(1000000, 6);

%% loop through all pixels and scales to identify the scale space maxima
waitbar(0, waitBarHandle, 'Extracting 4D Scale Space Extrema');
for s=1:(length(scaleRange))
    currentScale = squeeze(scaleSpace(:,:,:,s));
    extremaThreshold = mean(currentScale(:)) + 2*std(currentScale(:));
    
    for i=1:size(inputImage,1)
        for j=1:size(inputImage,2)
            for k=1:size(inputImage,3)

                %% get the current value
                currentValue = scaleSpace(i,j,k,s);

                %% skip processing if the value is below the threshold
                if (currentValue < extremaThreshold)
                    continue;
                end
                
                %% specify the ranges to search for maxima
                rangeX = max(1, i-1):min(i+1, size(scaleSpace,1));
                rangeY = max(1, j-1):min(j+1, size(scaleSpace,2));
                rangeZ = max(1, k-1):min(k+1, size(scaleSpace,3));

                %% check if current value is the maximum in the 4D neighborhood
                currentMaxValue = squeeze(max(max(max(max(scaleSpace(rangeX, rangeY, rangeZ, :))))));
                if (currentValue < currentMaxValue)
                    continue;
                end

                %% add the current scale space maximum
                scaleSpaceExtrema(currentId, :) = [currentId, scaleRange(s), j, i, k, currentValue];
                currentId = currentId+1;
            end
        end
    end
    
    %% update the wait bar
    waitbar(s / (size(scaleSpace,4)-1), waitBarHandle);
end

%% only report the valid extrema
scaleSpaceExtrema = scaleSpaceExtrema(1:(currentId-1), :);

%% remove the wait bar
close(waitBarHandle);