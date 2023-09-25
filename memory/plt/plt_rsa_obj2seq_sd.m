function plt_rsa_obj2seq_sd(rsa_same,rsa_diff,subject,plot_window)
% plot the rsa between object recognition and object recognition task, contains 4 pictures
% 1. same picture RSA 
% 2. different picture RSA
% 3. same picture - different picture RSA
% 4. paired t-test
%
% input:
%   rsa_same: matrix of same picture RSA values, data format: times*times*trials
%   rsa_diff: matrix of different picture RSA values, data format: times*times*trials
%   subject: subject identifier, such as 'subject1'
%   plot_window: position of the plot window, such as [x, y, width, height]
%
% output: 
%   none

figure

% Subplot 1: RSA values for same pictures
subplot(221)
imagesc(mean(rsa_same,3))
yticks(0:20:200);
yticklabels([0:20:200]/100);
ylabel('Object pic /s')
yline(50,'--')
yline(165,'--')
xticks(0:50:700);
xticklabels([-200:50:500]/100);
xlabel('Sequence pic /s')
xline(200,'--')
xline(450,'--')
title([subject,': same picture RSA'])
temp2=caxis;
colorbar()

% Subplot 2: RSA values for different pictures
subplot(222)
imagesc(mean(rsa_diff,3))
yticks(0:10:200);
yticklabels([-50:10:150]/100);
ylabel('Object pic /s')
yline(50,'--')
yline(165,'--')
xticks(0:50:700);
xticklabels([-200:50:500]/100);
xlabel('Sequence pic /s')
xline(200,'--')
xline(450,'--')
title([subject,': different picture RSA (random)'])
caxis(temp2)
colorbar()

% Subplot 3: Difference between RSA values for same and different pictures
subplot(223)
imagesc(mean(rsa_same,3)-mean(rsa_diff,3))
yticks(0:10:200);
yticklabels([-50:10:150]/100);
ylabel('Object pic /s')
yline(50,'--')
yline(165,'--')
xticks(0:50:700);
xticklabels([-200:50:500]/100);
xlabel('Sequence pic /s')
xline(200,'--')
xline(450,'--')
title([subject,': same - different'])
colorbar()

% Perform t-test on rsa_same and rsa_diff
pic_corr_h=[];
for i=1:size(rsa_same,1)
    for j=1:size(rsa_same,2)
        [pic_corr_h(i,j),~]=ttest(squeeze(rsa_same(i,j,:)),squeeze(rsa_diff(i,j,:)));
    end
end

subplot(224)
% Display the h values of the t-test as an image
imagesc(pic_corr_h)
yticks(0:10:200);
yticklabels([-50:10:150]/100);
ylabel('Object pic /s')
yline(50,'--')
yline(165,'--')
xticks(0:50:700);
xticklabels([-200:50:500]/100);
xlabel('Sequence pic /s')
xline(200,'--')
xline(450,'--')
title([subject,': t-test '])
c = colorbar;
c.Ticks = [0, 1]; % set tick values to 0 and 1
c.TickLabels = {'p>0.05', 'p<0.05'};

set(gcf, 'Position', plot_window);

% Display the number of subjects or picture pairs used in the analysis
if strcmp(subject,'Group')
    text(350,350,['subjects number=',num2str(size(rsa_same,3))],'FontSize',12,'HorizontalAlignment','center');
else
    text(350,350,['picture pair=',num2str(size(rsa_same,3))],'FontSize',12,'HorizontalAlignment','center');
end
end