%% perform the colocalization if the threshold was changed
if (settings.dirtyFlag == true)
    PerformColocalization;
    updateVisualization;
end

if (~isfield(settings, 'backgroundDots'))
    GenerateBackgroundDots;
    updateVisualization;
end


%% write unfiltered seed points
%         dlmwrite([settings.outputFolder settings.file1 '_unfiltered.csv'], settings.seedPoints1, ';');
%         dlmwrite([settings.outputFolder settings.file2 '_unfiltered.csv'], settings.seedPoints2, ';');
%         prepend2file('id;scale;xpos;ypos;zpos;intensity;seedPoint3D;seedPointCombinations;meanWindowIntensity;snrCriterion;integratedIntensity', [settings.outputFolder settings.file1 '_unfiltered.csv'], 1);
%         prepend2file('id;scale;xpos;ypos;zpos;intensity;seedPoint3D;seedPointCombinations;meanWindowIntensity;snrCriterion;integratedIntensity', [settings.outputFolder settings.file2 '_unfiltered.csv'], 1);

%% write filtered seed points
thresholdSuffix = ['_t1=' num2str(settings.globalThreshold(1)) '_t2=' num2str(settings.globalThreshold(2))];
dlmwrite([settings.outputFolder settings.file1 thresholdSuffix '_filtered.csv'], settings.seedPoints1Filtered, ';');
dlmwrite([settings.outputFolder settings.file2 thresholdSuffix '_filtered.csv'], settings.seedPoints2Filtered, ';');
prepend2file('id;scale;xpos;ypos;zpos;intensity;meanWindowIntensity;snrCriterion;integratedIntensity;meanWindowIntensity2;snrCriterion2;integratedIntensity2', [settings.outputFolder settings.file1 thresholdSuffix '_filtered.csv'], 1);
prepend2file('id;scale;xpos;ypos;zpos;intensity;meanWindowIntensity;snrCriterion;integratedIntensity;meanWindowIntensity2;snrCriterion2;integratedIntensity2', [settings.outputFolder settings.file2 thresholdSuffix '_filtered.csv'], 1);

%% write colocalized seed points
dlmwrite([settings.outputFolder settings.file1 thresholdSuffix '_colocalizations.csv'], settings.colocalizations1, ';');
dlmwrite([settings.outputFolder settings.file2 thresholdSuffix '_colocalizations.csv'], settings.colocalizations2, ';');
prepend2file('id;scale;xpos;ypos;zpos;intensity;meanWindowIntensity;snrCriterion;integratedIntensity;meanWindowIntensity2;snrCriterion2;integratedIntensity2;matchDistance;radius;intensityRatio', [settings.outputFolder settings.file1 thresholdSuffix '_colocalizations.csv'], 1);
prepend2file('id;scale;xpos;ypos;zpos;intensity;meanWindowIntensity;snrCriterion;integratedIntensity;meanWindowIntensity2;snrCriterion2;integratedIntensity2;matchDistance;radius;intensityRatio', [settings.outputFolder settings.file2 thresholdSuffix '_colocalizations.csv'], 1);

%% identify the non-colocalized seed points
%         unColocalized1 = settings.seedPoints1Filtered(~ismember(settings.seedPoints1Filtered(:,1), settings.colocalizations1),:);
%         unColocalized2 = settings.seedPoints2Filtered(~ismember(settings.seedPoints2Filtered(:,1), settings.colocalizations2),:);
dlmwrite([settings.outputFolder settings.file1 thresholdSuffix '_uncolocalized.csv'], settings.unColocalized1, ';');
dlmwrite([settings.outputFolder settings.file2 thresholdSuffix '_uncolocalized.csv'], settings.unColocalized2, ';');
prepend2file('id;scale;xpos;ypos;zpos;intensity;meanWindowIntensity;snrCriterion;integratedIntensity;meanWindowIntensity2;snrCriterion2;integratedIntensity2', [settings.outputFolder settings.file1 thresholdSuffix '_uncolocalized.csv'], 1);
prepend2file('id;scale;xpos;ypos;zpos;intensity;meanWindowIntensity;snrCriterion;integratedIntensity;meanWindowIntensity2;snrCriterion2;integratedIntensity2', [settings.outputFolder settings.file2 thresholdSuffix '_uncolocalized.csv'], 1);

if (isfield(settings, 'backgroundDots'))
    dlmwrite([settings.outputFolder settings.file1 thresholdSuffix '_backgroundSamples.csv'], settings.backgroundDots, ';');
    prepend2file('id;scale;xpos;ypos;zpos;intensity;meanWindowIntensity;snrCriterion;integratedIntensity;meanWindowIntensity2;snrCriterion2;integratedIntensity2', [settings.outputFolder settings.file1 thresholdSuffix '_backgroundSamples.csv'], 1);
end

%% add separator char at the first line
%         prepend2file('sep=;', [settings.outputFolder settings.file1 '_unfiltered.csv'], 1);
%         prepend2file('sep=;', [settings.outputFolder settings.file2 '_unfiltered.csv'], 1);
prepend2file('sep=;', [settings.outputFolder settings.file1 thresholdSuffix '_filtered.csv'], 1);
prepend2file('sep=;', [settings.outputFolder settings.file2 thresholdSuffix '_filtered.csv'], 1);
prepend2file('sep=;', [settings.outputFolder settings.file1 thresholdSuffix '_colocalizations.csv'], 1);
prepend2file('sep=;', [settings.outputFolder settings.file2 thresholdSuffix '_colocalizations.csv'], 1);
prepend2file('sep=;', [settings.outputFolder settings.file1 thresholdSuffix '_uncolocalized.csv'], 1);
prepend2file('sep=;', [settings.outputFolder settings.file2 thresholdSuffix '_uncolocalized.csv'], 1);

resultFile = fopen([settings.outputFolder settings.file2 thresholdSuffix  '_ResultsOverview.txt'], 'wb');
fprintf(resultFile, '------------------------ Files ------------------------\n');
fprintf(resultFile, 'File Channel 1: %s\n', settings.file1);
fprintf(resultFile, 'File Channel 2: %s\n\n', settings.file2);

fprintf(resultFile, '---------------------- Parameters ---------------------\n');
fprintf(resultFile, 'd_lateral (mu): %f\n', settings.physicalSpacingXY);
fprintf(resultFile, 'd_axial (mu): %f\n', settings.physicalSpacingZ);
fprintf(resultFile, 'sigma_pre (mu): %f\n', settings.gaussianSigma);
fprintf(resultFile, 'sigma_min (mu): %f\n', settings.minSigma);
fprintf(resultFile, 'sigma_max (mu): %f\n', settings.maxSigma);
fprintf(resultFile, 'n_scale: %f\n', settings.numScales);
%fprintf(resultFile, 'Weighted Centroid: %f\n', settings.weightedCentroid);
fprintf(resultFile, 'd_coloc: %f\n\n', settings.colocalizationCriterion);
fprintf(resultFile, 'axial coloc. factor: %f\n\n', settings.axialColocalizationFactor);
fprintf(resultFile, 'Use 4D scale-space: %f\n', settings.use4DScaleSpace);

fprintf(resultFile, 'Gamma: %f, %f\n', settings.gamma(1), settings.gamma(2));
fprintf(resultFile, 'Global Threshold: %f, %f\n', settings.globalThreshold(1), settings.globalThreshold(2));
fprintf(resultFile, 'SNR Threshold: %f, %f\n', settings.snrThreshold(1), settings.snrThreshold(2));
fprintf(resultFile, 'Fusion Radius: %f\n\n', settings.fuseRedundantSeeds * settings.physicalSpacingXY);

fprintf(resultFile, '----------------------- Results -----------------------\n');
fprintf(resultFile, 'Total Detections Channel 1: %i\n', size(settings.seedPoints1,1));
fprintf(resultFile, 'Total Detections Channel 2: %i\n\n', size(settings.seedPoints2,1));
fprintf(resultFile, 'Thresholded Detections Channel 1: %i\n', size(settings.seedPoints1Filtered,1));
fprintf(resultFile, 'Thresholded Detections Channel 2: %i\n\n', size(settings.seedPoints2Filtered,1));
fprintf(resultFile, 'Colocalized Detections Channel 1: %i\n', size(settings.colocalizations1,1));
fprintf(resultFile, 'Colocalized Detections Channel 2: %i\n\n', size(settings.colocalizations2,1));
fprintf(resultFile, 'Uncolocalized Detections Channel 1: %i\n', size(settings.unColocalized1,1));
fprintf(resultFile, 'Uncolocalized Detections Channel 2: %i\n\n', size(settings.unColocalized2,1));
fprintf(resultFile, 'Percentage Colocalized Detections Channel 1: %.2f%%\n', 100*size(settings.colocalizations1,1)/size(settings.seedPoints1Filtered,1));
fprintf(resultFile, 'Percentage Colocalized Detections Channel 2: %.2f%%\n\n', 100*size(settings.colocalizations2,1)/size(settings.seedPoints2Filtered,1));
fprintf(resultFile, 'Percentage Uncolocalized Detections Channel 1: %.2f%%\n', 100*size(settings.unColocalized1,1)/size(settings.seedPoints1Filtered,1));
fprintf(resultFile, 'Percentage Uncolocalized Detections Channel 2: %.2f%%\n', 100*size(settings.unColocalized2,1)/size(settings.seedPoints2Filtered,1));
fclose(resultFile);