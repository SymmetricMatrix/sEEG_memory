function plt_bar_group(data,group_name)
% plot bar plot with line plot for each sample,only support 2 group now
% Input: data, 3D matrix, group * each group * sample
%        group_name
% Output: None


% Calculate mean and standard deviation
data_mean =mean(data,3);
data_std = std(data,0,3);


h_bar = bar(data_mean, 0.8);
h_position = zeros(size(data_mean));
h_mean = zeros(size(data_mean));

for k1 = 1:size(data_mean,2)
    h_position(1:size(data_mean,1),k1) = bsxfun(@plus, h_bar(k1).XData, h_bar(k1).XOffset');
    h_mean(1:size(data_mean,1),k1) = h_bar(k1).YData;
end


hold on
errorbar(h_position, h_mean, data_std, '.k', 'CapSize', 2, 'MarkerSize', 6);

% Add title, axis labels, and legend
title('Mean and Individual changes');
xlabel('Group');
ylabel('Mean');
xticklabels(group_name);

%set(gcf, 'Position', [1 25 1920 1080]);
end

