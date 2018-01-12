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

%% function to re-estimate a Gaussian spot based on the current location, radius and a raw image
function [centroid, radius] = ReestimateGaussianSpot(currentLocation, currentRadius, currentImage)
 
    global settings;

    %% specify the inner radius (3 * std. dev.)
    innerRadius = settings.radiusMultiplier*round(currentRadius);
    
    %% calculate the inner and outer ranges
    rangeX = round(max(1, currentLocation(1)-innerRadius):min(size(currentImage,2), currentLocation(1)+innerRadius));
    rangeY = round(max(1, currentLocation(2)-innerRadius):min(size(currentImage,1), currentLocation(2)+innerRadius));
    rangeZ = round(max(1, currentLocation(3)-round(innerRadius/settings.zscale)):min(size(currentImage,3), currentLocation(3)+round(innerRadius/settings.zscale)));
            
    %% extract intensity properties of the channel where the seeds were detected
    innerSnippet = currentImage(rangeY, rangeX, rangeZ);
    x = zeros(1,4);
    exitflag = 0;
    if (length(rangeZ) > 1)
        
        %% desired output dimensions
        ny=size(innerSnippet,1);
        nx=size(innerSnippet,2);
        nz=round(size(innerSnippet,3)*settings.zscale);
        
        %% scale the image to be isotropic
        [y, x, z]= ndgrid(linspace(1,size(innerSnippet,1),ny),...
                          linspace(1,size(innerSnippet,2),nx),...
                          linspace(1,size(innerSnippet,3),nz));
        innerSnippet=interp3(innerSnippet,x,y,z);

        %% get the 3D indices from the linear index
        [X, Y, Z] = ind2sub(size(innerSnippet), 1:length(innerSnippet(:)));

        %% specify the functional to optimize
        fun = @(x) sum(innerSnippet(:) .* LaplacianOfGaussian([Y(:), X(:), Z(:)], [x(1),x(2),x(3)]', abs([x(4), x(4), x(4)]'), true));
        
        %% specify the initial location to start the optimization from
        %% global coordinates are transformed to local coordinates of the snippet
        x0 = [currentLocation(2) - min(rangeY), currentLocation(1) - min(rangeX), (currentLocation(3) - min(rangeZ))*settings.zscale, currentRadius];

        %% perform the actual optimization
        %options = optimset('Display','iter','PlotFcns',@optimplotfval);
        [x, ~, exitflag] = fminsearch(fun, x0);
        
        %% convert the local snippet coordinates back to global coordinates
        x(1) = x(1) + min(rangeY) - 1;
        x(2) = x(2) + min(rangeX) - 1;
        x(3) = (x(3) + min(rangeZ)*settings.zscale - 1) / settings.zscale;
    end

    %% set the result variables only if optimization exited with success
    if (exitflag == 1)
        centroid = x([2,1,3]);
        radius = x(4);
    else
        centroid = currentLocation;
        radius = currentRadius;
    end
end