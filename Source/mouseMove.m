function mouseMove(~, ~)
    global settings;
    currentPosition = get(gca, 'currentpoint');
    currentPosition = round([currentPosition(1,1), currentPosition(1,2)]);

    if (settings.showIDs == true)

        if (isempty(settings.idLabelHandle) || ~isvalid(settings.idLabelHandle))
            settings.idLabelHandle = text(0,0,'');
        end

        [channel1Index, channel1Distance] = knnsearch(settings.currentKDTree1, currentPosition, 'K', 1);
        [channel2Index, channel2Distance] = knnsearch(settings.currentKDTree2, currentPosition, 'K', 1);


        if ((channel1Distance < channel2Distance && settings.currentChannel == 3) || settings.currentChannel == 1)
            set(settings.idLabelHandle, 'Position', [settings.seedPoints1Filtered(channel1Index, 3)+0.5, settings.seedPoints1Filtered(channel1Index, 4), 0]);
            set(settings.idLabelHandle, 'String', ['ID = ' num2str(settings.seedPoints1Filtered(channel1Index, 1)) ', Pos = ' num2str(settings.seedPoints1Filtered(channel1Index, 3:5)) ', Radius = ' num2str(settings.seedPoints1Filtered(channel1Index, 2)*sqrt(2))]);
            set(settings.idLabelHandle, 'Color', [1,0,0]);
        end
        
        if ((channel1Distance >= channel2Distance && settings.currentChannel == 3) || settings.currentChannel == 2)
            set(settings.idLabelHandle, 'Position', [settings.seedPoints2Filtered(channel2Index, 3)+0.5, settings.seedPoints2Filtered(channel2Index, 4), 0]);
            set(settings.idLabelHandle, 'String', ['ID = ' num2str(settings.seedPoints2Filtered(channel2Index, 1)) ', Pos = ' num2str(settings.seedPoints2Filtered(channel2Index, 3:5)) ', Radius = ' num2str(settings.seedPoints2Filtered(channel2Index, 2)*sqrt(2))]);
            set(settings.idLabelHandle, 'Color', [0,1,0]);
        end
    end
end