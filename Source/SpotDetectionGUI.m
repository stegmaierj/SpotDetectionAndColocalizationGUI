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

%% initialize the global settings variable
close all; 
clear all;
global settings;

%% ask for voxel resulution
prompt = {'Lateral Voxel Size (xy):','Axial Voxel Size (z):', 'Minimum Object Diameter in Pixel (3,5,7,...)', 'Maximum Object Diameter in Pixel (3,5,7,...)', 'Gaussian Smoothing Variance (Default: 1)', 'Weighted Centroid (Default: 0)', 'Coloc. Criterion (-1: Bound. Sphere Int., >=0: Max Centroid Dist. in Pixel)', 'Axial Coloc. Factor (1: Same as lateral, <1: Allow larger distances)'};
dlg_title = 'Provide Project Settings';
num_lines = 1;
defaultans = {'0.0624','0.42', '3', '9', '1', '0', '-1', '1'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
settings.physicalSpacingXY = str2double(answer{1});
settings.physicalSpacingZ = str2double(answer{2});
settings.zscale = str2double(answer{2}) / str2double(answer{1});
settings.minSigma = ((str2double(answer{3})-1)/2);
settings.maxSigma = ((str2double(answer{4})-1)/2);
settings.gaussianSigma = str2double(answer{5});
settings.weightedCentroid = str2double(answer{6}) > 0;
settings.colocalizationCriterion = str2double(answer{7});
settings.axialColocalizationFactor = str2double(answer{8});
settings.fuseRedundantSeeds = 0;
settings.sigmaStep = 0.1;
settings.offset = 1;
settings.maximumProjectionMode = true;
settings.currentSlice = 1;
settings.snrThreshold = [1, 1];
settings.gamma = [1,1];
settings.globalThreshold = [0, 0];
settings.thresholdChannel = 1;
settings.thresholdMode = 1;
settings.radiusMultiplier = 4;
settings.currentChannel = 3;
settings.intensityIndex = 6;
settings.colormapIndex = 1;
settings.colormap = 'jet';
settings.fontSize = 14;
settings.axesEqual = false;
settings.dirtyFlag = true;
settings.showIDs = false;
settings.showBackgroundDots = false;
settings.showScaleBar = false;
settings.idLabelHandle = [];
settings.showColocalization = true;
settings.showDetections = true;
settings.colormapStrings = {'gray', 'parula', 'jet'};

%% adjust the xml template according to the selected input
templateFile = fopen('XPIWIT/LoGSpotDetectionTemplate.xml', 'rb');
xmlFile = fopen('XPIWIT/LoGSpotDetection.xml', 'wb');

currentLine = fgets(templateFile);
while ischar(currentLine)
    
    currentLine = strrep(currentLine, '%ZVSXYRATIO%', num2str((settings.zscale)));
    currentLine = strrep(currentLine, '%SIGMASTEP%', num2str((settings.sigmaStep)));
    currentLine = strrep(currentLine, '%MINSIGMA%', num2str((settings.minSigma)));
    currentLine = strrep(currentLine, '%MAXSIGMA%', num2str((settings.maxSigma)));
    currentLine = strrep(currentLine, '%GAUSSIANSIGMA%', num2str((settings.gaussianSigma)));
    
    fprintf(xmlFile, currentLine);
    currentLine = fgets(templateFile);
end

fclose(templateFile);
fclose(xmlFile);


if (~isdeployed())
    addpath('ThirdParty/saveastiff_4.3/');
end

%% specify inputfiles
[filename1, pathname1] = uigetfile({'*.tif', 'TIFF-Image'; '*.*', 'ITK Compatible Single Channel Image'}, 'Please select channel 1 image (single channel 3D Tiff file)', 'MultiSelect', 'off');
[filename2, pathname2] = uigetfile({'*.tif', 'TIFF-Image'; '*.*', 'ITK Compatible Single Channel Image'}, 'Please select channel 2 image (single channel 3D Tiff file)', 'MultiSelect', 'off');
settings.inputChannel1Absolute = [pathname1 filename1];
settings.inputChannel2Absolute = [pathname2 filename2];
settings.outputFolder = [uigetdir(pwd, 'Please select output folder') filesep];
% settings.inputChannel1Absolute = '/Users/jstegmaier/GoogleDrive/Projects/2016/Caltech/Projects/AlexSpotDetection/Data/C1-S3-EphA4-60min-1-hyperstack-substack25_42-512.tif';
% settings.inputChannel2Absolute = '/Users/jstegmaier/GoogleDrive/Projects/2016/Caltech/Projects/AlexSpotDetection/Data/C2-S3-EphA4-60min-1-hyperstack-substack25_42-512.tif';
% settings.outputFolder = '/Users/jstegmaier/GoogleDrive/Projects/2016/Caltech/Projects/AlexSpotDetection/Processing/';

%% perform seed detection for channel1
if (ispc)
    cd XPIWIT\Windows\
elseif (ismac)
    cd XPIWIT/MacOSX/
elseif (isunix)
    cd XPIWIT/Ubuntu/
end

XPIWITCommand1 = ['./XPIWIT.sh ' ...
                 '--output "' settings.outputFolder '" ' ...
                 '--input "0, ' settings.inputChannel1Absolute ', 3, float" ' ...
                 '--xml "../LoGSpotDetection.xml" ' ...
                 '--seed 0 --lockfile off --subfolder "filterid, filtername" --outputformat "imagename, filtername" --end'];

if (ispc == true)
    XPIWITCommand1 = strrep(XPIWITCommand1, './XPIWIT.sh', 'XPIWIT.exe');
    XPIWITCommand1 = strrep(XPIWITCommand1, '\', '/');
end             
system(XPIWITCommand1);

%% perform seed detection for channel2
XPIWITCommand2 = ['./XPIWIT.sh ' ...
                 '--output "' settings.outputFolder '" ' ...
                 '--input "0, ' settings.inputChannel2Absolute ', 3, float" ' ...
                 '--xml "../LoGSpotDetection.xml" ' ...
                 '--seed 0 --lockfile off --subfolder "filterid, filtername" --outputformat "imagename, filtername" --end'];

if (ispc == true)
    XPIWITCommand2 = strrep(XPIWITCommand2, './XPIWIT.sh', 'XPIWIT.exe');
    XPIWITCommand2 = strrep(XPIWITCommand2, '\', '/');
end
system(XPIWITCommand2);
cd ../../;

%% extract the file parts
[folder1, settings.file1, ext1] = fileparts(settings.inputChannel1Absolute);
[folder2, settings.file2, ext2] = fileparts(settings.inputChannel2Absolute);

%% load raw images
settings.imageChannel1 = im2double(loadtiff(settings.inputChannel1Absolute));
settings.imageChannel2 = im2double(loadtiff(settings.inputChannel2Absolute));
settings.imageChannel1MaxProj = (max(settings.imageChannel1, [], 3));
settings.imageChannel2MaxProj = (max(settings.imageChannel2, [], 3));
settings.minIntensity = min(min(settings.imageChannel1(:)), min(settings.imageChannel2(:)));
settings.maxIntensity = max(max(settings.imageChannel1(:)), max(settings.imageChannel2(:)));

settings.xLim = [0, size(settings.imageChannel1,1)];
settings.yLim = [0, size(settings.imageChannel1,2)];

%% adjust the scale conversion factor depending on the image dimensionality
if (size(settings.imageChannel1, 3) > 1)
    settings.scaleConversionFactor = sqrt(1.5);
else
    settings.scaleConversionFactor = 1;
end

%% load detected seed points
settings.seedPoints1 = dlmread([settings.outputFolder 'item_0006_ExtractLocalExtremaFilter/' settings.file1 '_ExtractLocalExtremaFilter_KeyPoints.csv'], ';', 1, 0);
settings.seedPoints2 = dlmread([settings.outputFolder 'item_0006_ExtractLocalExtremaFilter/' settings.file2 '_ExtractLocalExtremaFilter_KeyPoints.csv'], ';', 1, 0);
settings.seedPoints1Filtered = settings.seedPoints1;
settings.seedPoints2Filtered = settings.seedPoints2;
PrepareSeedPoints;

settings.globalThresholdStep = (max(max(settings.imageChannel1(:)), max(settings.imageChannel2(:))) - min(min(settings.imageChannel1(:)), min(settings.imageChannel2(:)))) / 1000;

settings.mainFigure = figure(1);

%% mouse, keyboard events and window title
set(settings.mainFigure, 'WindowScrollWheelFcn', @scrollEventHandler);
set(settings.mainFigure, 'KeyReleaseFcn', @keyReleaseEventHandler);
set(settings.mainFigure, 'WindowButtonDownFcn', @mouseUp);
set(settings.mainFigure, 'WindowButtonMotionFcn', @mouseMove);
set(settings.mainFigure, 'CloseRequestFcn', @closeRequestHandler);

%% update the visualization
updateVisualization;