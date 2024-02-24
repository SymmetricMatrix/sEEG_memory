% data check
% before running this code, make sure you have completed the following steps:
% 1. brainstorm
% 2. updata tabel  in '/bigvault/Projects/seeg_pointing/gather'
% 3. updata event_code.m
%%
clc
clear
%% setting subject and directory
sub_id = 37;
subject = ['subject',num2str(sub_id)];
proj = 'object_recognition';%'object_recognition''sequence_memory'

home_dir = '/bigvault/Projects/seeg_pointing/';
sub_dir= dir(fullfile([home_dir,'subject/',subject,'/seeg_edf/',proj],'*.edf'));
read_dir=[sub_dir.folder,'/',sub_dir.name];
save_dir = [home_dir,'results/',proj,'/',subject];
mkdir(save_dir)
% read header info
header = ft_read_header(read_dir);
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
% data_trigger.trial{1,1}=trigger;

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
proj = 'sequence_memory';%'sequence_memory'
for sub_id = 1:27
    subject = ['subject',num2str(sub_id)];
    try
        cfg = [];
        read_dir = fullfile('/bigvault/Projects/seeg_pointing/results/sequence_memory',subject);
        cfg.dataset = fullfile(read_dir, 'trigger.mat');
        cfg.trialfun = 'ft_trialfun_edf';
        cfg.trialdef.pre = epoch_duration(1);
        cfg.trialdef.post = epoch_duration(2);
        cfg.threshold = 7;
        cfg = ft_definetrial(cfg);
        
        if strcmp(proj, 'sequence_memory')
            % Define the event codes based on the subject number
            cfg.trl(:, 5) = event_code(sub_id);
        end
        
        save(fullfile(read_dir, [subject, '_cfg.mat']), 'cfg', '-v7.3');
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end
%%
% subject 33
trigger(1386750:1396950)=0;
trigger(1396950-20:1396950)=2;

%%
srate=[];
for sub_id =1:27
    try
load(['/bigvault/Projects/seeg_pointing/results/sequence_memory/subject',num2str(sub_id),'/trigger.mat'])
srate(sub_id,1)=data_trigger.fsample;
 catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end



% delete 

data_selected_normalized = wavelet.powspctrm;
idx = setdiff(1:57, [1,2,10,40:47,51:54]);
right = [3:6,12,12,15,20:21,28:30,35:37,48:54];
%idx = intersect(idx,right);
idx = setdiff(idx,right);
idx =1:57;
figure
data = squeeze(mean(data_selected_normalized(:,idx,1:50,512*2.5+1:512*7.5),2));
plt_wavelet_pic18(data)
sg = sgtitle(['condition: non bd, chan num:',num2str(size(data_selected_normalized,2))]);
sg.FontWeight = 'bold';
sg.FontSize = 14;
%% plot hippcampus


