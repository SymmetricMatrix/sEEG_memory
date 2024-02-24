function plt_rsa_seq_sd(rsa_same, rsa_diff, subject, plot_window)
% plot object recognition task same and diff picture, contains 4 pictures
% 1. same picture RSA 
% 2. different picture RSA
% 3. same picture - different picture RSA
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

% Create a figure with four subplots
figure
subplot(221)
% Display the mean of rsa_same as an image
imagesc(mean(rsa_same,3))
yticks(0:25:250);
yticklabels([0:25:250]/100);
ylabel('Current pic /s')
xticks(0:25:200);
xticklabels([250:25:450]/100);
xlabel('After /s')
title([subject,': boundary'])
temp2=caxis;
axis square
colorbar()

subplot(222)
% Display the mean of rsa_diff as an image
imagesc(mean(rsa_diff,3))
yticks(0:25:250);
yticklabels([0:25:250]/100);
ylabel('Current pic /s')
xticks(0:25:200);
xticklabels([250:25:450]/100);
xlabel('After /s')
title([subject,': non boundary'])
caxis(temp2)
axis square
colorbar()

subplot(223)
% Display the difference between the mean of rsa_same and rsa_diff as an image
imagesc(mean(rsa_same,3)-mean(rsa_diff,3))
yticks(0:25:250);
yticklabels([0:25:250]/100);
ylabel('Current pic /s')
xticks(0:25:200);
xticklabels([250:25:450]/100);
xlabel('After /s')
title([subject,': boundary - non boundary '])
axis square
colorbar()

% Perform t-test on rsa_same and rsa_diff
pic_corr_p=[];
for i=1:size(rsa_same,1)
    for j=1:size(rsa_same,2)
        [~,pic_corr_p(i,j)]=ttest(squeeze(rsa_same(i,j,:)),squeeze(rsa_diff(i,j,:)));
    end
end

subplot(224)
% Display the h values of the t-test as an image
imagesc(pic_corr_p<0.05)
yticks(0:25:250);
yticklabels([0:25:250]/100);
ylabel('Current pic /s')
xticks(0:25:200);
xticklabels([250:25:450]/100);
xlabel('After /s')
title([subject,': ttest'])
axis square
c = colorbar;
c.Ticks = [0, 1]; % set tick values to 0 and 1
c.TickLabels = {'p>0.05', 'p<0.05'}; % set tick labels to 'ÎÞ' and 'ÓÐ'

set(gcf, 'Position', plot_window);

% Display the number of subjects or picture pairs used in the analysis
if strcmp(subject,'Group')
    text(350,250,['subjects number=',num2str(size(rsa_same,3))],'FontSize',12,'HorizontalAlignment','center');
else
    text(350,250,['picture pair=',num2str(size(rsa_same,3))],'FontSize',12,'HorizontalAlignment','center');
end

end
