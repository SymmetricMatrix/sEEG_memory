function plt_rsa_seq_pre_after(rsa_seq, subject, plot_window)
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
yticks(0:20:200);
yticklabels([-250:20:-50]/100); % set y-axis tick labels
ylabel('Pre ITI/s')
xticks(0:20:200);
xticklabels([250:20:450]/100); % set x-axis tick labels
xlabel('Current ITI/s')
title([subject,': Sequence RSA Pre vs After']) % set the title of the plot
daspect([1,1,1])
colorbar()

set(gcf, 'Position', plot_window); % set the position of the plot window
end