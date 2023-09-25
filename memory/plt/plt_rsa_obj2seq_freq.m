function plt_rsa_obj2seq_freq(rsa_same, rsa_diff, subject, plot_window)
% This function plots four subplots of imagesc plots.
% Inputs:
%   rsa_same: A matrix that represents same picture RSA data.
%   rsa_diff: A matrix that represents different picture RSA data.
%   subject: A string that represents the subject name.
%   plot_window: A vector that represents the position of the figure window.
% Outputs:
%   None.

% Plot the first subplot of same picture RSA data.
figure
subplot(221)
imagesc(mean(rsa_same,3))
yticks(1:2:46);
yticklabels([2:2:29,30:10:119]);
ylabel('Frequency/Hz')
xticks(0:25:200);
xticklabels([-50:25:150]/100);
xlabel('Time/s')
title([subject,': same picture RSA diag'])
temp2=caxis;
colorbar()

% Plot the second subplot of different picture RSA data.
subplot(222)
imagesc(mean(rsa_diff,3))
yticks(1:2:46);
yticklabels([2:2:29,30:10:119]);
ylabel('Frequency/Hz')
xticks(0:25:200);
xticklabels([-50:25:150]/100);
xlabel('Time/s')
title([subject,': different picture RSA'])
caxis(temp2)
colorbar()

% Plot the third subplot of the difference between same and different picture RSA data.
subplot(223)
imagesc(mean(rsa_same,3)-mean(rsa_diff,3))
yticks(1:2:46);
yticklabels([2:2:29,30:10:119]);
ylabel('Frequency/Hz')
xticks(0:25:200);
xticklabels([-50:25:150]/100);
xlabel('Time/s')
title([subject,': same - different'])
temp3=caxis;
colorbar()

% Perform t-test on same and different picture RSA data and plot the fourth subplot.
pic_corr_t=[];
for i=1:size(rsa_diff,1)
    for j=1:size(rsa_diff,2)
        [h,p]=ttest2(rsa_same(i,j,:),rsa_diff(i,j,:));
        pic_corr_t(i,j)=-log(p);
    end
end

subplot(224)
imagesc(pic_corr_t)
yticks(1:2:46);
yticklabels([2:2:29,30:10:119]);
ylabel('Frequency/Hz')
xticks(0:25:200);
xticklabels([-50:25:150]/100);
xlabel('Time/s')
title([subject,': t-test -log(p) value'])
temp4=caxis;
colorbar()

% Set the position of the figure window.
set(gcf, 'Position', plot_window);
end