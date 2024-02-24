function plt_box_line(data,group_name) 
% plot bar plot with line plot for each sample,only support 2 group now
% Input: data, two columns
%        group_name
% Output: None

% Sample data
x =  data(:,1);
y =  data(:,2);

% Calculate mean and standard deviation
mean_x = mean(x);
mean_y = mean(y);
std_x = std(x);
std_y = std(y);

% Plot bar graph of sample means
% bar([1, 2], [mean_x, mean_y]);

boxchart(data)

hold on;
for i=1:length(x)
    plot(1:2,[x(i),y(i)],'bo--', 'MarkerFaceColor', [107,173,217]/256, 'Color', [160,160,160]/256)
end
% Add error bars for sample variability
%errorbar([1, 2], [mean_x, mean_y], [std_x, std_y], 'k.', 'LineWidth', 1);
[p,t] = ttest(x,y);
if p==1
    plot([1,2],ones(2,1)*max(max(data))*1.02,'k','LineWidth',2)
    if t >0.01
        text(1.5, max(max(data))*1.04, '*','HorizontalAlignment','center','FontSize',16)
    elseif  t >0.001
        text(1.5, max(max(data))*1.04, '**','HorizontalAlignment','center','FontSize',16)
    else
        text(1.5, max(max(data))*1.04, '***','HorizontalAlignment','center','FontSize',16)
    end
end
% Add title, axis labels, and legend
title('Mean and Individual changes');
xlabel('Group');
ylabel('Mean');
xticklabels(group_name);

%set(gcf, 'Position', [1 25 1920 1080]);
end
