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

%% Compute LoG function values
%% x: input vector with rows being single data points
%% mu: column vector containing the mean of the Gaussian
%% sigma: column vector containing the standard deviations along the three axes 
%%        or a single standard deviation for all dimensions
%% normalizeAcrossScales: if set to true, the result is scaled with the current sigma
function y = LaplacianOfGaussian(x, mu, sigma, normalizeAcrossScales)

    %% convert standard deviations to a vector with identical entries 
    %% if only one standard deviation is provided
    if (length(sigma) == 1)
        sigma = ones(size(mu)) * sigma;
    end
    
    %% compute the normalization factor
    d = length(mu);
    c = 1 / (sqrt((2*pi)^d*det(diag(sigma.^2))));
        
    %% compute the LoG of the input values
    if (d==1)
        
        %% solution for one dimension
        y = c * exp( -0.5 * ...
                    (((x(:,1) - mu(1))/sigma(1)) .^2)) .* ...
                    ((((x(:,1) - mu(1)).^2 ./ sigma(1)^4) - 1 / sigma(1)^2));

        %% optionally apply the normalization
        if (normalizeAcrossScales == true)
            y = y * (sigma(1));
        end
    elseif (d==2)
        %% solution for two dimensions
        y = c * exp( -0.5 * ...
                    (((x(:,1) - mu(1))/sigma(1)) .^2 + ...
                     ((x(:,2) - mu(2))/sigma(2)) .^2)) .* ...
                    ((((x(:,1) - mu(1)).^2 ./ sigma(1)^4) - 1 / sigma(1)^2) + ...
                     (((x(:,2) - mu(2)).^2 ./ sigma(2)^4) - 1 / sigma(2)^2));

        %% optionally apply the normalization
        if (normalizeAcrossScales == true)
            y = y * (sigma(1) .^ 2);
        end
    elseif (d==3)
        %% solution for three dimensions
        y = c * exp( -0.5 * ...
                    (((x(:,1) - mu(1))/sigma(1)) .^2 + ...
                     ((x(:,2) - mu(2))/sigma(2)) .^2 + ...
                     ((x(:,3) - mu(3))/sigma(3)) .^2)) .* ...
                    ((((x(:,1) - mu(1)).^2 ./ sigma(1)^4) - 1 / sigma(1)^2) + ...
                     (((x(:,2) - mu(2)).^2 ./ sigma(2)^4) - 1 / sigma(2)^2) + ...
                     (((x(:,3) - mu(3)).^2 ./ sigma(3)^4) - 1 / sigma(3)^2));

        %% optionally apply the normalization
        if (normalizeAcrossScales == true)
            y = y * (sigma(1) .^ 2.5);
        end
    else
        disp('Only dimensionalities {1, 2, 3} are supported!');
    end
end