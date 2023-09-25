function plt_text_cover(plt_level,subject,plot_window)
figure('Color','white');
text(0.5,0.5,plt_level,'FontSize',60,'HorizontalAlignment','center');
text(0.5,0.3,['Subject=',num2str(subject)],'FontSize',15,'HorizontalAlignment','center');
axis off
set(gcf, 'Position', plot_window);
end