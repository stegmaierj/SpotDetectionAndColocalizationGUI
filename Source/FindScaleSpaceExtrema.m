%% function to find scale space extrema in the log scale space
function scaleSpaceExtrema = FindScaleSpaceExtrema(inputImage, scaleSpace, spacing, scaleRange, extremaThreshold)

%% add fft convolution path
addpath('ThirdParty/convnfft');
addpath('ThirdParty/saveastiff_4.3/');

% zscale = spacing(3) / spacing(1);
% height = size(inputImage,1); 
% width  = size(inputImage,2);
% depth  = round(size(inputImage,3) * zscale);
% 
% [y, x, z] = ndgrid(linspace(1,size(inputImage,1), height), ...
%                    linspace(1,size(inputImage,2), width), ...
%                    linspace(1,size(inputImage,3), depth));
% inputImage = interp3(inputImage, x, y, z, 'linear');
% spacing(3) = spacing(1);

% %% initialize the log kernels
% logKernels = cell(length(scaleRange), 1);
% 
% %% initialize the scale space
% scaleSpace = zeros(size(inputImage,1), size(inputImage,2), size(inputImage,3), length(scaleRange));
% 
 %% create the scale space representation of the image
waitBarHandle = waitbar(0, 'Creating LoG Scale Space');
% for i=1:length(scaleRange)
%    
%    %% create the log filter and perform the convolution for the current scale
%    logKernels{i} = CreateLoGFilter(scaleRange(i), spacing, true);
%    scaleSpace(:,:,:,i) = convnfft(inputImage, logKernels{i}, 'same');
%    
%        
% %    figure(2); clf;
% %     subplot(2,3,1);
% %     imagesc(squeeze(max(logKernels{i}, [], 3)));
% %     
% %     subplot(2,3,2);
% %     imagesc(squeeze(max(logKernels{i}, [], 2)));
% %     
% %     subplot(2,3,3);
% %     imagesc(squeeze(max(logKernels{i}, [], 1)));
% %     
% %     currentImage = squeeze(scaleSpace(:,:,:,i));
% %     subplot(2,3,4);
% %     imagesc(squeeze(max(currentImage, [], 3)));
% %     
% %     subplot(2,3,5);
% %     imagesc(squeeze(max(currentImage, [], 2)));
% %     
% %     subplot(2,3,6);
% %     imagesc(squeeze(max(currentImage, [], 1)));
% %     title(num2str(scaleSpace(51,41,7,i)));
% %     
% %    
% %    
% %    clear options;
% %    options.overwrite = true;
% %    options.compress = 'lzw';
% %    saveastiff(uint16(squeeze(scaleSpace(:,:,:,i))*65535), ['ScaleSpace_scale=' num2str(i) '.tif'], options);
%    
%    %% update the wait bar
%    waitbar(i / length(scaleRange), waitBarHandle);
% end

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
    
    for i=2:(size(inputImage,1)-1)
        for j=2:(size(inputImage,2)-1)
            for k=2:(size(inputImage,3)-1)


                %% get the current value
                currentValue = scaleSpace(i,j,k,s);

%                 if (i==41 && j == 51 && k == 6)
%                     test = 1;
%                                     figure(2);
%                 plot(squeeze(scaleSpace(i, j, k, :)));
%                 end

                %% skip processing if the value is below the threshold
                if (currentValue < extremaThreshold)
                    continue;
                end

                %% check if current value is the maximum in the 4D neighborhood
                currentMaxValue = squeeze(max(max(max(max(scaleSpace(i-1:i+1, j-1:j+1, k-1:k+1, :))))));
                if (currentValue < currentMaxValue)
                    continue;
                end

                %% add the current scale space maximum
%                 figure(2);
%                 plot(squeeze(scaleSpace(i, j, k, :)));

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