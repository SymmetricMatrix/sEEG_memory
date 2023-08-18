% plot template
%% only word
plot_window=[1 25 1920 1080];

figure('Color','white');
text(0.5,0.5,'Your text here','FontSize',30,'HorizontalAlignment','center');
axis off

% max plot window
set(gcf, 'Position', plot_window);

%% export figure to pdf
export_fig([read_dir,'RSA_freq.pdf'], '-pdf','-append','-nocrop');