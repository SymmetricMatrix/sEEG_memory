function plt_rsa_obj2seq_region123(rsa_seq_full_group,subject,plot_window,method)
% This function plots RSA results for three regions of interest and a comparison between two time windows.
% flatten sequence,left object
% 1. Plot the mean correlation for each region with confidence intervals
% 2. Plot significant correlations as an image
% 
% Inputs:
%   rsa_seq_full_group: RSA results for all subjects
%   subject: Name of the subject or group.
%   plot_window: Position of the plot window.
%   method: Statistical method used for significance testing (sigrank or ttest).

% Define RGB values for colors
red = [217 83 25]/255;
blue = [0 114 189]/255;
yellow = [249 172 50]/255;

seq_pre = 1:200;  % original [-5,7], save [-2.5,5], pre interval [-2.5,-0.5]
seq_after = 501:700;

% Calculate mean correlation for each region
region1 = squeeze(mean(rsa_seq_full_group(:,seq_pre,:),2));
region2 = squeeze(mean(rsa_seq_full_group(:,seq_after,:),2));

ylims = size(rsa_seq_full_group,1);

% Plot the mean correlation for each region with confidence intervals
figure
subplot(121)
plot_ci(region1', red, 0.05)
hold on
plot_ci(region2', yellow, 0.05)

% Find significant correlations using the specified method
plt_sig = max(mean([region1;region2],2));
p = [];
h = [];
if strcmp(method,'sigrank')
    for i = 1:size(region1,1)
        [p(1,i),h(1,i)] = signrank(region1(i,:), region2(i,:));
    end
elseif strcmp(method,'ttest')
    for i = 1:size(region1,1)
        [h(1,i),p(1,i)] = ttest2(region1(i,:), region2(i,:));
    end
end

% Plot significant correlations as stars
idx = find(h(1,:) == 1);
plot(idx, ones(size(idx))*plt_sig*1.1, '*', 'MarkerSize',3.5,'MarkerFaceColor',red,'MarkerEdgeColor', red)
% Add legend and labels

ylabel('Correlation')
xticks(0:10:200);
xticklabels([-50:10:150]/100);
xlabel('Picture present /s')
xline(50,'--')
xline(165,'--')
legend('pre','','after','','Location','SouthEast')
title([subject, ': Sequence correlation ', method])

subplot(122)
region1 = rsa_seq_full_group(:,1:200,:);
region3 = rsa_seq_full_group(:,501:700,:);

% Find significant correlations between regions 1 and 3
p = [];
h = [];
if strcmp(method,'sigrank')
    for i = 1:size(region1,1)
        for j = 1:size(region1,2)
            [p(i,j),h(i,j)] = signrank(squeeze(region1(i,j,:)), squeeze(region3(i,j,:)), 'tail', 'both');
        end
    end
elseif strcmp(method,'ttest')
    for i = 1:size(region1,1)
        for j = 1:size(region1,2)
            [h(i,j),p(i,j)] = ttest2(squeeze(region1(i,j,:)), squeeze(region3(i,j,:)), 'tail', 'both');
        end
    end
end

% Plot significant correlations as an image
imagesc(h)
xticks(0:10:200);
xticklabels([-50:10:150]/100);
yticks(0:10:200);
yticklabels([-50:10:150]/100);
ylabel('Object (sequence -2~0s)/s')
xlabel('Object (sequence 3~5s)/s')
xline(50,'--')
xline(165,'--')
yline(50,'--')
yline(165,'--')
title([subject, ': Sequence ', method, ' -2-0s vs 3-5s (p<0.05)'])
axis square
set(gcf, 'Position', plot_window);


end