function zoomCorrection(object, eventdata)
    
    %% get the limits of the current axes
    global settings;

    settings.xLim = get(gca, 'XLim');
    settings.yLim = get(gca, 'YLim');
    
    updateVisualization;
end