function plt_rsa_obj_diag(rsa_same,rsa_diff,subject,lag,plot_window)
% This function plots the RSA diagonal and different picture RSA for a given subject and lag.
% 1. paired t-test(p<0.05)
% 2. RSA diagonal of same pic pair and different pic pair
%
% Inputs:
%   rsa_same: matrix of same picture RSA values, data format: times*times*trials
%   rsa_diff: matrix of different picture RSA values, data format: times*times*trials
%   subject: subject identifier, such as 'subject1'
%   lag: lag value for different picture RSA, int
%   plot_window: position of the plot window, such as [x, y, width, height]
%
% Outputs: none

% set color
red=[217 83 25]/255;
blue=[0 114 189]/255;
deep_red = [236 43 36]/255;
deep_blue = [29 65 121]/255;

% get diag
for k=1:size(rsa_same,3)
    rsa_same_diag(:,k)=diag(squeeze(rsa_same(:,:,k)));
    rsa_diff_diag(:,k)=diag(squeeze(rsa_diff(:,:,k)));
end

% t-test same & diff
pic_corr_h=[];
pic_corr_p=[];

for i=1:size(rsa_same,1)
    for j=1:size(rsa_same,2)
        % perform t-test for each pair of RSA values
        [pic_corr_h(i,j),pic_corr_p(i,j)]=ttest(squeeze(rsa_same(i,j,:)),squeeze(rsa_diff(i,j,:)));
    end
end

figure
% plot RSA diagonal with confidence intervals
plot_ci(rsa_same_diag',red,0.05)
hold on
plot_ci(rsa_diff_diag',blue,0.05)
xticks(0:25:200);
xticklabels([-50:25:150]/100);
xline(100,'--')
xline(125,'--')
xlabel('present pic /s')
ylabel('correlation')
title(['RSA diagonal'])
% plot significant RSA values as red dots
diag_corr = diag(pic_corr_h);
idx = find(diag_corr == 1);
plot(idx, ones(size(idx))*max(mean([rsa_same_diag,rsa_diff_diag],2))*1.2, 'o', 'MarkerSize',3.5,'MarkerFaceColor',deep_red,'MarkerEdgeColor', deep_red)
legend('Same picture','','Different picture','','p<0.05')

title([subject,': different picture RSA diag(lag=',num2str(lag),')'])

set(gcf, 'Position', plot_window);
end
