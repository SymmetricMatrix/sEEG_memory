function plot_ci_sig(data1, data2)
    % set color
    red=[217 83 25]/255;
    blue=[0 114 189]/255;
    deep_red = [236 43 36]/255;
    deep_blue = [29 65 121]/255;


    % Calculate the confidence interval and significance
    [h, p, ci] = ttest(data1,data2);
    
    % Plot the data and confidence intervals
    hold on
    plot_ci(data1,red,0.1)
    plot_ci(data2,blue,0.1)

    idx = find(h == 1);
    plot(idx, ones(size(idx))*max(mean([data1,data2],2))*1.2, 'o', 'MarkerSize',3.5,'MarkerFaceColor',deep_red,'MarkerEdgeColor', deep_red)
    

    % Label the plot with the confidence intervals and significance
    legend('Data1','','Data2','','p<0.05')
    xlabel('X');
    ylabel('Y');
    title('Confidence Intervals And Significant difference');
    
end

