clc
clear
%% parameter setting
home_dir='/bigvault/Projects/seeg_pointing/';
proj='sequence_memory';
save_dir=[home_dir,'results/',proj,'/'];

% plot
plot_window=[1 25 1920 1080];
fig_export_dir = [save_dir,'RSA_sequence_region123_trials.pdf'];
subjects=[1,2,3,4,7,8,9,10,12,13,15,16,17];
%% plot
k=1;
rsa_seq_full_group = [];
for sub_id=subjects
    subject = strcat('subject', num2str(sub_id));
    try
       load([save_dir,subject,'/',subject,'_sequence_sw.mat'])
     
       rsa_seq_full = rsa_temp1(sequence_sw(:,:,[201:450],:),sequence_sw(:,:,[351:700],:));
       rsa_seq_full_group(:,:,k) = rsa_seq_full;
       k=k+1;
       disp([num2str(sub_id),': done'])
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end
% rsa_trials.rsa_seq_full_group=rsa_seq_full_group;
% rsa_trials.subjects=subjects;
% save([save_dir,'rsa_seq_full_group_alltrials.mat'],'rsa_seq_full_group');
% save([save_dir,'rsa_trials.mat'],'rsa_trials')
%% caculate sequence and object rsa
% subject cover
set(0,'DefaultFigureVisible','off');
subject = 'Group';

plt_text_cover(subject,subjects, plot_window)
export_fig(fig_export_dir, '-pdf','-append','-nocrop');

plt_rsa_obj2seq_region123(rsa_seq_full_group,subject,plot_window,'sigrank')
export_fig(fig_export_dir, '-pdf','-append','-nocrop');

plt_rsa_obj2seq_region123(rsa_seq_full_group,subject,plot_window,'ttest')
export_fig(fig_export_dir, '-pdf','-append','-nocrop');

plt_text_cover('Group No Fixation',subjects, plot_window)
export_fig(fig_export_dir, '-pdf','-append','-nocrop');

plt_rsa_obj2seq_region1234(rsa_seq_full_group,subject,plot_window,'sigrank')
export_fig(fig_export_dir, '-pdf','-append','-nocrop');

plt_rsa_obj2seq_region1234(rsa_seq_full_group,subject,plot_window,'ttest')
export_fig(fig_export_dir, '-pdf','-append','-nocrop');



