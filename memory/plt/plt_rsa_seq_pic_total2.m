function plt_rsa_seq_pic_total2(rsa_seq, subject, plot_window)
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
seq_pre = 1:200;  % original [-5,7], save [-2.5,5], pre interval [-2.5,-0.5]
seq_after = 501:700;% original [-5,7], save [-2.5,5], pre interval [2.5,4.5]
red = [217 83 25]/255;
blue = [0 114 189]/255;

data_pre = rsa_seq(:,seq_pre,:);
data_after = rsa_seq(:,seq_after,:);
figure
subplot(221)
imagesc(mean(data_pre,3))

subplot(222)
imagesc(mean(data_after,3))

subplot(223)
% Perform t-test on rsa_same and rsa_diff
pic_corr_h=[];
for i=1:size(data_pre,1)
    for j=1:size(data_pre,2)
        [pic_corr_h(i,j),~]=ttest(squeeze(data_pre(i,j,:)),squeeze(data_after(i,j,:)));
    end
end
imagesc(pic_corr_h)

% plot 
subplot(224)
% Calculate mean correlation for each region
pre = squeeze(mean(rsa_seq(:,seq_pre,:),2));
after= squeeze(mean(rsa_seq(:,seq_after ,:),2));

plot_ci(pre', red, 0.05)
hold on
plot_ci(after', blue, 0.05)

% Find significant correlations using the specified method
plt_sig = max(mean([pre;after],2));
p = [];
h = [];
for i = 1:size(pre,1)
    [h(1,i),p(1,i)] = signrank(pre(i,:), after(i,:));
end

% Plot significant correlations as stars
idx = find(h(1,:) == 1);
plot(idx, ones(size(idx))*plt_sig*1.1, '*', 'MarkerSize',3.5,'MarkerFaceColor',red,'MarkerEdgeColor', red)

% Add legend and labels
ylabel('Correlation')
xticks(0:25:250);
xticklabels([0:25:250]/100);
xlabel('Picture present /s')
legend('pre','','after','','Location','SouthEast')
title([subject, ': Sequence correlation(signrank)'])


set(gcf, 'Position', plot_window);
end