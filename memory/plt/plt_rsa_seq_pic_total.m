function plt_rsa_seq_pic_total(rsa_seq, subject, plot_window)
% This function creates a plot of the sequence RSA for a given subject, where 
% the y-axis represents the picture present and the x-axis represents the whole trial.
%
% Inputs:
%   rsa_seq: the RSA sequence, data format: times*times*trials,total 
%   subject: the subject, data format: 'subject1'
%   plot_window: the position of the plot window
%
% Outputs:
%   None
seq_pic = 251:500;% original [-5,7], save [-2.5,5], pic [0,2.5]
seq_pre = 51:200;  % original [-5,7], save [-2.5,5], pre interval [-2.5,-0.5]
seq_after = 551:700;% original [-5,7], save [-2.5,5], pre interval [2.5,4.5]
red = [217 83 25]/255;
blue = [0 114 189]/255;

rsa_pre = rsa_seq(:,seq_pre,:);
rsa_after = rsa_seq(:,seq_after,:);

figure
subplot(2,3,[1:2])
% plot rsa_seq_pic_total imagesc
imagesc(mean(rsa_seq,3)); % plot the RSA sequence as an image
yticks(0:25:250);
yticklabels([0:25:250]/100); % set y-axis tick labels
ylabel('Picture Present/s')
xticks(0:25:750);
xticklabels([-250:25:500]/100); % set x-axis tick labels
xlabel('Total Trial /s')
title([subject,': Sequence RSA Pic Present vs Total']) % set the title of the plot
daspect([1,1,1])
colorbar()

% plot pre
subplot(2,3,4)
% plot rsa_seq_pic_total imagesc
imagesc(mean(rsa_pre,3)); % plot the RSA sequence as an image
yticks(0:25:250);
yticklabels([0:25:250]/100); % set y-axis tick labels
ylabel('Picture Present/s')
xticks(0:25:200);
xticklabels([-250:25:-50]/100); % set x-axis tick labels
xlabel('Pre /s')
title([subject,': Sequence RSA(Present vs pre)']) % set the title of the plot
daspect([1,1,1])
colorbar()
climits = caxis;

% plot after
subplot(2,3,5)
% plot rsa_seq_pic_total imagesc
imagesc(mean(rsa_after,3)); % plot the RSA sequence as an image
yticks(0:25:250);
yticklabels([0:25:250]/100); % set y-axis tick labels
ylabel('Picture Present/s')
xticks(0:25:200);
xticklabels([250:25:450]/100); % set x-axis tick labels
xlabel('After /s')
title([subject,': Sequence RSA(Present vs after)']) % set the title of the plot
daspect([1,1,1])
colorbar()
caxis(climits);
% 
subplot(2,3,3)
% Calculate mean correlation for each region
pre = squeeze(mean(rsa_pre,2));
after= squeeze(mean(rsa_after,2));
%after = flipud(after);
plot_ci(pre', red, 0.05)
hold on
plot_ci(after', blue, 0.05)

% Find significant correlations using the specified method
plt_sig = max(mean([pre;after],2));
p = [];
h = [];
for i = 1:size(pre,1)
    [h(1,i),p(1,i)] = ttest(pre(i,:), after(i,:));
end
% Plot significant correlations as stars
idx = find(h(1,:) == 1);
plot(idx, ones(size(idx))*plt_sig*1.1, '*', 'MarkerSize',3.5,'MarkerFaceColor',red,'MarkerEdgeColor', red)
ylabel('Correlation')
xticks(0:25:250);
xticklabels([0:25:250]/100);
xlabel('Picture present /s')
legend('pre: -2.5~-0.5s','','after:2.5~4.5s','','Location','NorthEast')
title([subject, ': Sequence correlation(ttest)'])


% Perform t-test on rsa_same and rsa_diff
subplot(2,3,6)
pic_corr_h=[];
for i=1:size(rsa_pre,1)
    for j=1:size(rsa_pre,2)
        [pic_corr_h(i,j),~]=ttest(squeeze(rsa_pre(i,j,:)),squeeze(rsa_after(i,j,:)));
    end
end
imagesc(pic_corr_h)
yticks(0:25:250);
yticklabels([0:25:250]/100); % set y-axis tick labels
ylabel('present /s')
xticks(0:25:200);
xticklabels([250:25:450]/100); % set x-axis tick labels
xlabel('Pre/After /s')
title([subject,': Sequence RSA Present vs after(ttest)']) % set the title of the plot
daspect([1,1,1])
colorbar()


set(gcf, 'Position', plot_window); % set the position of the plot window
end