%% filter the seed points based on the current SNR threshold
validIndices1 = settings.seedPoints1(:,settings.snrRatioIndex) > settings.snrThreshold(1) & settings.seedPoints1(:,settings.meanIntensityIndex) > settings.globalThreshold(1);
settings.seedPoints1Filtered = settings.seedPoints1(validIndices1, :);

validIndices2 = settings.seedPoints2(:,settings.snrRatioIndex) > settings.snrThreshold(2) & settings.seedPoints2(:,settings.meanIntensityIndex) > settings.globalThreshold(2);
settings.seedPoints2Filtered = settings.seedPoints2(validIndices2, :);
settings.dirtyFlag = true;
settings.showColocalization = false;

settings.currentKDTree1 = KDTreeSearcher(settings.seedPoints1Filtered(:,3:4));
settings.currentKDTree2 = KDTreeSearcher(settings.seedPoints2Filtered(:,3:4));
settings.colocalizations1 = [];
settings.colocalizations2 = [];