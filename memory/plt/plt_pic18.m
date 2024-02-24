function plt_pic18(data,type)
% This function ids to plot 18 subplots
% Input: Data,time*time*18

figure
for i =1:size(data,3)
    subplot(3,6,i)
    imagesc(data(:,:,i))
    if i==1
        climit = caxis;
    else
        caxis(climit)
    end
    colorbar()
    switch type
        case 'pre_after'
            yticks(0:50:200);
            yticklabels([-250:50:-50]/100); % set y-axis tick labels
            ylabel('Pre ITI/s')
            xticks(0:50:200);
            xticklabels([250:50:450]/100); % set x-axis tick labels
            xlabel('Current ITI/s')
            title(['Picture',num2str(i),': Pre vs After']) % set the title of the plot
            daspect([1,1,1])
        case 'pic_after'
            yticks(0:50:250);
            yticklabels([0:50:250]/100); % set y-axis tick labels
            ylabel('Picture present/s')
            xticks(0:50:200);
            xticklabels([250:50:450]/100); % set x-axis tick labels
            xlabel('ITI/s')
            title(['Picture',num2str(i),': Pic vs After']) % set the title of the plot
            daspect([1,1,1])
    end
        
end
set(gcf, 'Position', [1 25 1920 1080]);
end
