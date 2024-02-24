function plt_rsa_obj2seq_pre_after(rsa_same,subject,plot_window,method,fix)
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
switch fix
    case 'contains_fixation'
        seq_pre = 1:250;  % original [-5,7], save [-2.5,5], pre interval [-2.5,-0]
        seq_after = 501:750; % original [-5,7], save [-2.5,5], pre interval [2.5,5]
    case 'without_fixation'
        seq_pre = 1:200;  % original [-5,7], save [-2.5,5], pre interval [-2.5,-0.5]
        seq_after = 501:700; % original [-5,7], save [-2.5,5], pre interval [2.5,4.5]
end

% Calculate mean correlation for each region
region1 = squeeze(mean(rsa_same(:,seq_pre,:),2));
region2 = squeeze(mean(rsa_same(:,seq_after,:),2));

ylims = size(rsa_same,1);

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
        [h(1,i),p(1,i)] = ttest(region1(i,:), region2(i,:));
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
% Find significant correlations between regions 1 and 3
region1 = rsa_same(:,seq_pre,:);
region2 = rsa_same(:,seq_after,:);
p = [];
h = [];
switch method
    case 'sigrank'
        for i = 1:size(region1,1)
            for j = 1:size(region1,2)
                [p(i,j),h(i,j)] = signrank(squeeze(region1(i,j,:)), squeeze(region2(i,j,:)), 'tail', 'both');
            end
        end
    case 'ttest'
        for i = 1:size(region1,1)
            for j = 1:size(region1,2)
                [h(i,j),p(i,j)] = ttest(squeeze(region1(i,j,:)), squeeze(region2(i,j,:)), 'tail', 'both');
            end
        end
end

% Plot significant correlations as an image
imagesc(h)
yticks(0:10:200);
yticklabels([-50:10:150]/100);
ylabel('Object /s')
xticks(0:20:250);
xticklabels([250:20:500]/100);
xlabel('Sequence /s')
yline(50,'--')
yline(165,'--')
xline(200,'--')
title([subject, ': Sequence ', method, ' pre vs after (p<0.05)'])
axis square
set(gcf, 'Position', plot_window);


end