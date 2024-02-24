function plt_wavelet_sd(data_bd, data_non_bd, subject, plot_window)
% plot sequence memory task boundary and non_boundary wavelet result
% 1. boundary wavelet,cell type
% 2. non_boundary wavelet,cell type
% 3. boundary wavelet - non_boundary wavelet
% 4. paired t-test, h
%
% input:
%   rsa_same: matrix of same picture RSA values, data format: times*times*trials
%   rsa_diff: matrix of different picture RSA values, data format: times*times*trials
%   subject: subject identifier, such as 'subject1'
%   lag: lag value for different picture RSA, int
%   plot_window: position of the plot window, such as [x, y, width, height]
%
% output:
%   none
time = [-1,3.5];
time_point = size(data_bd{1,1},2);
srate= time_point/(time(2)-time(1));

% Create a figure with four subplots
figure
for seqi=1:6
    subplot(4,6,seqi)
    bd = cell2matrix(data_bd(:, seqi));
    bd = bd(1:25,:,:);
    clim = plt_imagesc(mean(bd,3),'wavelet');
    if seqi ==1
        climits = clim;
    end
    caxis([-climits,climits]);
    
    subplot(4,6,seqi+6)
    non_bd = cell2matrix(data_non_bd(:, seqi));
    non_bd = non_bd(1:25,:,:);
    plt_imagesc(mean(non_bd,3),'wavelet');
    caxis([-climits,climits]);
    
    subplot(4,6,seqi+12)
    plt_imagesc(mean(bd-non_bd,3),'wavelet');
    title('bd-non bd')
    
    subplot(4,6,seqi+18)
    pic_corr_h=[];
    for i=1:size(bd,1)
        for j=1:size(bd,2)
            [pic_corr_h(i,j),~]=ttest(squeeze(bd(i,j,:)),squeeze(non_bd(i,j,:)));
        end
    end
    plt_imagesc(pic_corr_h,'wavelet');
    title(['t-test '])
    c = colorbar;
    c.Ticks = [0, 1]; % set tick values to 0 and 1
    c.TickLabels = {'p>0.05', 'p<0.05'};
    
end
sgtitle(subject)
set(gcf, 'Position', plot_window);
end
