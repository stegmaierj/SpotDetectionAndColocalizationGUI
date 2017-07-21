function mouseUp(~, ~)

%% get global variables
global settings;

%% get current modifier keys
modifiers = get(gcf,'currentModifier');        %(Use an actual figure number if known)
shiftPressed = ismember('shift',modifiers);
ctrlPressed = ismember('control',modifiers);
altPressed = ismember('alt',modifiers);
currentButton = get(gcbf, 'SelectionType');
clickPosition = get(gca, 'currentpoint');
clickPosition = round([clickPosition(1,1), clickPosition(1,2)]);

%% add the click point as a positive or negative coexpression point including mean intensity calculations
if (ctrlPressed == true)

elseif (shiftPressed == true)

end

%% update the visualization
updateVisualization;

end