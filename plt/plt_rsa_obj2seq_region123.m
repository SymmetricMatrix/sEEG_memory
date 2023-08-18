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


% Calculate mean correlation for each region
region1 = squeeze(mean(rsa_seq_full_group(:,1:200,:),2));
region2 = squeeze(mean(rsa_seq_full_group(:,451:500,:),2));
region3 = squeeze(mean(rsa_seq_full_group(:,501:700,:),2));

ylims = size(rsa_seq_full_group,1);

% Plot the mean correlation for each region with confidence intervals
figure
subplot(121)
plot_ci(region1', red, 0.05)
hold on
plot_ci(region2', yellow, 0.05)
plot_ci(region3', blue, 0.05)

% Find significant correlations using the specified method
plt_sig = max(mean([region1;region2;region3],2));
p = [];
h = [];
if strcmp(method,'sigrank')
    for i = 1:size(region1,1)
        [p(1,i),h(1,i)] = signrank(region1(i,:), region2(i,:));
        [p(2,i),h(2,i)] = signrank(region1(i,:), region3(i,:));
        [p(3,i),h(3,i)] = signrank(region2(i,:), region3(i,:));
    end
elseif strcmp(method,'ttest')
    for i = 1:size(region1,1)
        [h(1,i),p(1,i)] = ttest2(region1(i,:), region2(i,:));
        [h(2,i),p(2,i)] = ttest2(region1(i,:), region3(i,:));
        [h(3,i),p(3,i)] = ttest2(region2(i,:), region3(i,:));
    end
end

% Plot significant correlations as stars
idx = find(h(1,:) == 1);
plot(idx, ones(size(idx))*plt_sig*1.1, '*', 'MarkerSize',3.5,'MarkerFaceColor',red,'MarkerEdgeColor', red)
idx = find(h(2,:) == 1);
plot(idx, ones(size(idx))*plt_sig*1.3, '*', 'MarkerSize',3.5,'MarkerFaceColor',blue,'MarkerEdgeColor', blue)
idx = find(h(3,:) == 1);
plot(idx, ones(size(idx))*plt_sig*1.2, '*', 'MarkerSize',3.5,'MarkerFaceColor',yellow,'MarkerEdgeColor', yellow)

% Add legend and labels
legend('-2-0s','','2.5-3s','','3-5s','','Location','SouthEast')
ylabel('Correlation')
xticks(0:20:250);
xticklabels([0:20:250]/100);
xlabel('Picture present /s')
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
xticks(0:20:250);
xticklabels([0:20:250]/100);
yticks(0:20:ylims);
yticklabels([0:20:ylims]/100);
ylabel('Object present/s')
xlabel('Sequence present/s')
title([subject, ': Sequence ', method, ' -2-0s vs 3-5s (p<0.05)'])
axis square
set(gcf, 'Position', plot_window);

% Add text to the plot
if strcmp(subject,'Group')
    text(820,143,['Subjects number=',num2str(size(rsa_seq_full_group,3))],'FontSize',12,'HorizontalAlignment','center');
else
    text(820,143,['Picture pair=',num2str(size(rsa_seq_full_group,3))],'FontSize',12,'HorizontalAlignment','center');
end
end