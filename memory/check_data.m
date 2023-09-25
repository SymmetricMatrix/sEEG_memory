% data check
% before running this code, make sure you have completed the following steps:
% 1. brainstorm
% 2. updata tabel  in '/bigvault/Projects/seeg_pointing/gather'
% 3. updata event_code.m
%%
clc
clear
%% setting subject and directory
sub_id = 19;
subject = ['subject',num2str(sub_id)];
proj = 'sequence_memory';%'object_recognition''sequence_memory'

home_dir = '/bigvault/Projects/seeg_pointing/';
sub_dir= dir(fullfile([home_dir,'subject/',subject,'/seeg_edf/',proj],'*.edf'));
read_dir=[sub_dir.folder,'/',sub_dir.name];
save_dir = [home_dir,'results/',proj,'/',subject];
mkdir(save_dir)

%% check trigger
% check whether the trigger is correct and the trial number is accurate
% if not, generate a trigger_new.mat

% Read trigger channel
% if you encounter an "error opening file" report, change the file name from Chinese to English
cfg = [];
cfg.dataset = native2unicode(read_dir);
cfg.channel = 'TRIG';
data_trigger = ft_preprocessing(cfg);
trigger=cell2mat(data_trigger.trial);
save([save_dir,'/trigger.mat'],'data_trigger');
fprintf('Sampling rate is %d\n', data_trigger.fsample);


% Check trigger value, correct format: 0 1 2 3 100
tabulate(trigger)

% Trigger change
% If trigger needs to be changed, replace trigger.m with the right trigger_old.m as a backup.
% For subject1-17 see trigger_change_object.m or trigger_change_sequence.m.


% Check trial number, correct format: practice 36 + run 432
cfg = [];
cfg.dataset = [save_dir,'/trigger.mat'];
cfg.trialfun = 'ft_trialfun_edf';
cfg.trialdef.pre  = 5;
cfg.trialdef.post = 7;
cfg.threshold = 7;
cfg = ft_definetrial(cfg);



%% check label name
% check whether the EDF label and brainstorm match
% if not, change the label name



