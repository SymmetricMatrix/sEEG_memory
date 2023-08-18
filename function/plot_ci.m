function plot_ci(matrix,color,alpha,x_change)
% Input a two-dimensional matrix, plot a figure with a curve of mean values in the middle, and the corresponding confidence interval
% The x-axis should be the column number of the matrix
% x_change change x axis label in a suitable scale
if nargin<4
    x_change = 1;
end
    
x = (1:size(matrix,2))/x_change; % x-axis is the column number of the matrix
y = mean(matrix,1); % y-axis is the mean value of each column of the matrix
yconf = std(matrix,0,1) * 1.96 / sqrt(size(matrix,1)); % y-axis confidence interval, assuming 95% confidence level and normal distribution
xconf = [x x(end:-1:1)]; % x-axis confidence interval, including both directions
yconf = [y+yconf y(end:-1:1)-yconf(end:-1:1)]; % y-axis confidence interval, including upper and lower bound

plot(x,y,'Color',color,'LineWidth',2); % Plot the mean value curve with black thick line
hold on % Hold the current figure
fill(xconf,yconf,color,'FaceAlpha',alpha,'EdgeColor','none'); % Fill the confidence interval with cyan color
end