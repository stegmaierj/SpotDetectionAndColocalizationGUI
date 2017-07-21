%% scroll event handler
function scrollEventHandler(src,evnt)
    global settings;

    %% get the modifier keys
    modifiers = get(gcf,'currentModifier');        %(Use an actual figure number if known)
    shiftPressed = ismember('shift',modifiers);
    ctrlPressed = ismember('control',modifiers);
    altPressed = ismember('alt',modifiers);
    
   clickPosition = get(gca, 'currentpoint');
    clickPosition = [clickPosition(1,1), clickPosition(1,2)];

    if (ctrlPressed)
        figure(settings.mainFigure);

        oldXLim = get(gca, 'XLim');
        oldYLim = get(gca, 'YLim');


        %% identify wheel direction
        if evnt.VerticalScrollCount < 0
            newWidth(1) = clickPosition(1) - abs(clickPosition(1)-oldXLim(1))/2;
            newWidth(2) = clickPosition(1) + abs(clickPosition(1)-oldXLim(2))/2;
            newHeight(1) = clickPosition(2) - abs(clickPosition(2)-oldYLim(1))/2;
            newHeight(2) = clickPosition(2) + abs(clickPosition(2)-oldYLim(2))/2;

        else

            newWidth(1) = clickPosition(1) - abs(clickPosition(1)-oldXLim(1))*2;
            newWidth(2) = clickPosition(1) + abs(clickPosition(1)-oldXLim(2))*2;
            newHeight(1) = clickPosition(2) - abs(clickPosition(2)-oldYLim(1))*2;
            newHeight(2) = clickPosition(2) + abs(clickPosition(2)-oldYLim(2))*2;
        end

        newLimits = [newWidth(1) newWidth(2) newHeight(1) newHeight(2)];

        axis(newLimits);
        settings.xLim = get(gca, 'XLim');
        settings.yLim = get(gca, 'YLim');
        %
        %         set(0,'Units', 'normalized', 'PointerLocation', [0.25, 0.5]);
    else
        if (settings.maximumProjectionMode == false)
            %% identify wheel direction
            if evnt.VerticalScrollCount > 0
                increment = -1;
            else
                increment = +1;
            end
            
            % change slice number due to wheel direction
            settings.currentSlice = settings.currentSlice + increment;
            
            % check whether current slice number is between 1 and max number
            settings.currentSlice = min(max(1,settings.currentSlice), size(settings.imageChannel1,3));
        end
    end
    
    %% update the visualization
    updateVisualization;
end