function plt_wavelet_region_bd(boundary_data, non_boundary_data, subject, plot_window)
% plot sequence memory task boundary and non_boundary wavelet result
% 1. boundary wavelet
% 2. non_boundary wavelet
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
time = [-2.5,5];
time_point = size(boundary_data,2);
srate= time_point/(time(2)-time(1));
% Create a figure with four subplots
figure

subplot(221)
% Display the mean of rsa_same as an image
imagesc(mean(boundary_data,3))
ylabel('Frequency /Hz')
xticks(0:srate/2:time_point);
xticklabels([time(1):0.5:time(2)]);
xlabel('Time /s')
title([subject,': boundary wavelet'])
xline(-srate*time(1),'-')
xline(srate*(2.5-time(1)),'-')
temp2=caxis;
axis square
colorbar()

subplot(222)
% Display the mean of rsa_diff as an image
imagesc(mean(non_boundary_data,3))
ylabel('Frequency /Hz')
xticks(0:srate/2:time_point);
xticklabels([time(1):0.5:time(2)]);
xlabel('Time /s')
title([subject,': non boundary wavelet'])
xline(-srate*time(1),'-')
xline(srate*(2.5-time(1)),'-')
caxis(temp2)
axis square
colorbar()

subplot(223)
% Display the difference between the mean of rsa_same and rsa_diff as an image
imagesc(mean(boundary_data,3)-mean(non_boundary_data,3))
ylabel('Frequency /Hz')
xticks(0:srate/2:time_point);
xticklabels([time(1):0.5:time(2)]);
xlabel('Time /s')
title([subject,': boundary - non boundary wavelet'])
xline(-srate*time(1),'--')
xline(srate*(2.5-time(1)),'--')
axis square
colorbar()

% Perform t-test on rsa_same and rsa_diff
pic_corr_h=[];
for i=1:size(boundary_data,1)
    for j=1:size(boundary_data,2)
        [pic_corr_h(i,j),~]=ttest(squeeze(boundary_data(i,j,:)),squeeze(non_boundary_data(i,j,:)));
    end
end

subplot(224)
% Display the h values of the t-test as an image
imagesc(pic_corr_h)
ylabel('Frequency /Hz')
xticks(0:srate/2:time_point);
xticklabels([time(1):0.5:time(2)]);
xlabel('Time /s')
xline(-srate*time(1),'--')
xline(srate*(2.5-time(1)),'--')
title([subject,': t-test '])
axis square
c = colorbar;
c.Ticks = [0, 1]; % set tick values to 0 and 1
c.TickLabels = {'p>0.05', 'p<0.05'}; % set tick labels to 'ÎÞ' and 'ÓÐ'

set(gcf, 'Position', plot_window);

end
