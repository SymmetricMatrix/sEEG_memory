function plt_rsa_obj2seq_flatten(rsa_same, rsa_diff, time_dim, subject, plot_window)
% This function plots RSA between same and different pictures and the difference between them.
% 1. plot flatten same and diff 
% 2. plot flatten same - diff
% 
% Inputs:
%   rsa_same: matrix of RSA values for same pictures, 115*750
%   rsa_diff: matrix of RSA values for different pictures
%   time_dim: flatten rsa matrix (1 for left sequence, 2 for left object)
%   subject: name of the subject, such as 'subject1'
%   plot_window: position of the plot window
%
% Outputs: none

% set color
red = [217 83 25]/255;
blue = [0 114 189]/255;
deep_red = [236 43 36]/255;
deep_blue = [29 65 121]/255;

% flatten data
rsa_same = squeeze(mean(rsa_same, time_dim));
rsa_diff = squeeze(mean(rsa_diff, time_dim));

% caculate ttest result
pic_corr_h = [];
pic_corr_p = [];
for i = 1:size(rsa_same, 1)
    [pic_corr_h(i), pic_corr_p(i)] = ttest(rsa_same(i,:), rsa_diff(i,:));
end


figure
subplot(2, 1, 1)
% plot flatten same and diff 
plot_ci(rsa_same', red, 0.09)
hold on
plot_ci(rsa_diff', blue, 0.09)
if time_dim == 1 
    xticks(0:50:700);
    xticklabels([-200:50:500]/100);
    xlabel('Sequence pic /s')
    title([subject,': RSA between sequence and object(Sequence)'])
elseif time_dim == 2
    xticks(0:10:120);
    xticklabels([0:10:120]/100);
    xlabel('Object pic /s')
    title([subject,': RSA between sequence and object(Object)'])
end
yline(0,'--')
idx = find(pic_corr_h == 1);
plot(idx, ones(size(idx))*max(mean(rsa_same,2))*1.2, 'o', 'MarkerSize',3.5,'MarkerFaceColor',deep_red,'MarkerEdgeColor', deep_red)
ylabel('Fisher Z')
legend('Same picture','','Different picture','','','p<0.05')

subplot(2, 1, 2)
% plot flatten same - diff 
plot_ci(rsa_same'-rsa_diff', deep_blue, 0.09)
if time_dim == 1 
    xticks(0:50:700);
    xticklabels([-200:50:500]/100);
    xlabel('Sequence pic /s')
    title([subject,': RSA same-diff(Sequence)'])
elseif time_dim == 2
    xticks(0:10:120);
    xticklabels([0:10:120]/100);
    xlabel('Object pic /s')
    title([subject,': RSA same-diff(Object)'])
end
yline(0,'--')
ylabel('Fisher Z')

set(gcf, 'Position', plot_window);
end