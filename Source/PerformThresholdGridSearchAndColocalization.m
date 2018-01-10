
%% get the user-defined ranges for the thresholds
prompt = {'min_threshold1:', 'max_threshold1:', 'min_threshold2:', 'max_threshold2:', 'n_steps:', 'save_intermediate_results:', 'show_result_figure:'};
dlg_title = 'Parameters for Threshold Grid Search';
num_lines = 1;
defaultans = {num2str(settings.globalThreshold(1)), num2str(2*settings.globalThreshold(1)), num2str(settings.globalThreshold(2)), num2str(2*settings.globalThreshold(2)), '10', '0', '1'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

%% skip processing if no parameters are provided
if (isempty(answer))
    disp('ERROR: No parameters provided -> Canceling grid search!');
    return;
end

%% extract the parameters
minThreshold1 = str2double(answer{1,1});
maxThreshold1 = str2double(answer{2,1});
minThreshold2 = str2double(answer{3,1});
maxThreshold2 = str2double(answer{4,1});
numSteps = str2double(answer{5,1});
saveIntermediateResults = str2double(answer{6,1}) > 0;
showResultFigure = str2double(answer{7,1}) > 0;
stepSize1 = (maxThreshold1 - minThreshold1) / (numSteps-1);
stepSize2 = (maxThreshold2 - minThreshold2) / (numSteps-1);
maxFScore = 0;
settings.backgroundDots = [];
optimizationLandscape = zeros(numSteps, numSteps);

%% temporary save the old threshold
oldGlobalThreshold = settings.globalThreshold;

%% initialize a progress bar
h = waitbar(0,'Performing grid search for the provided threshold range ...');

%% run through both threshold ranges and export the colocalization results
currentIndex1 = 1;
for t1=minThreshold1:stepSize1:maxThreshold1
    
    
    currentIndex2 = 1;
    for t2=minThreshold2:stepSize2:maxThreshold2
        
        %% set the current threshold values
        settings.globalThreshold(1) = t1;
        settings.globalThreshold(2) = t2;

        %% filter the seed points based on the current SNR threshold
        settings.showDetections = true;
        PerformSeedFiltering;
        PerformColocalization;
        
        %% export the results for the current settings
        if (saveIntermediateResults == true)
            ExportResults;
        end
        
        %% compute the current colocalization results
        colocalizations1 = size(settings.colocalizations1,1)/size(settings.seedPoints1Filtered,1);
        colocalizations2 = size(settings.colocalizations2,1)/size(settings.seedPoints2Filtered,1);
        fscore = 2 * (colocalizations1 * colocalizations2) / (colocalizations1 + colocalizations2);
        
        %% if the results were better than before, save as the best parameter pair
        if (fscore > maxFScore)
            maxFScore = fscore;
            bestThreshold1 = t1;
            bestThreshold2 = t2;
            bestColocalization1 = 100*colocalizations1;
            bestColocalization2 = 100*colocalizations2;
        end
        
        %% save the current fscore results
        optimizationLandscape(currentIndex1, currentIndex2) = fscore;
        
        %% increase the counter for the second threshold
        currentIndex2 = currentIndex2 + 1;
    end
    
    %% increase the counter for the first threshold
    currentIndex1 = currentIndex1 + 1;
    
    %% show status
    waitbar(currentIndex1 / numSteps);
end

%% show debug figure of the optimization landscape
if (showResultFigure == true)
    figure(2);
    [X, Y] = meshgrid(minThreshold1:stepSize1:maxThreshold1, minThreshold2:stepSize2:maxThreshold2);
    surf(X, Y, optimizationLandscape);
    xlabel('Threshold 1');
    ylabel('Threshold 2');
    zlabel('Combined colocalization score');
    title('Optimization landscape');
    colormap jet;
    grid on;
    axis auto;
end

%% close the progress bar
close(h);

%% reset the threshold to the value before the grid search
settings.globalThreshold = oldGlobalThreshold;
updateVisualization;

%% print best threshold message
msgbox(['Best threshold combination: t1 = ' num2str(bestThreshold1) ', t2 = ' num2str(bestThreshold2) ...
        ', coloc1: ' num2str(bestColocalization1) '%, coloc2: ' num2str(bestColocalization2) ...
        '%, combined: ' num2str(100*maxFScore) '%'], 'Grid Search Results');
settings = rmfield(settings, 'backgroundDots');