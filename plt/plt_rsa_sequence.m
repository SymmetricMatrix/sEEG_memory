function plt_rsa_sequence(rsa_seq, subject, plot_window)
% This function creates a plot of the sequence RSA for a given subject, where 
% the y-axis represents the picture present and the x-axis represents the whole trial.
%
% Inputs:
%   rsa_seq: the RSA sequence, data format: times*times*trials
%   subject: the subject, data format: 'subject1'
%   plot_window: the position of the plot window
%
% Outputs:
%   None

figure
imagesc(mean(rsa_seq,3)); % plot the RSA sequence as an image
yticks(0:25:250);
yticklabels([0:25:250]/100); % set y-axis tick labels
ylabel('Time/s')
xticks(0:25:700);
xticklabels([-200:25:500]/100); % set x-axis tick labels
xlabel('Time /s')
title([subject,': Sequence RSA']) % set the title of the plot
daspect([1,1,1])
colorbar()

set(gcf, 'Position', plot_window); % set the position of the plot window
end