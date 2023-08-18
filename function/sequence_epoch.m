function data_epoch=sequence_epoch(read_dir,data,threshold)
% data epoch

% input 
%     read_dir     -- dir for File path
%     data         -- fieldtrip format data,The pre-processed data
%     threshold    -- the data in trigger exceed the threshold are defined as trails

% output
%     data_epoch  -- fieldtrip format data,The epoch data

% Dependent function: 
%    event_code.m
    
% modification time: 20230715

% replace trigger
if exist(fullfile(read_dir, 'trigger_new.mat'),'file')
    load( fullfile(read_dir, 'trigger.mat'))
    load( fullfile(read_dir, 'trigger_new.mat'))
    data_trigger.trial{1}=trigger;
    save([read_dir,'/','trigger.mat'],'data_trigger','-v7.3');
end

% epoch
cfg = [];
cfg.dataset = fullfile(read_dir, 'trigger.mat');
cfg.trialfun = 'ft_trialfun_edf';
cfg.trialdef.pre  = 5;
cfg.trialdef.post = 7;
cfg.threshold = threshold;
cfg = ft_definetrial(cfg);

subject=regexp(cfg.dataset, 'subject(\d+)', 'match');
subject_num = str2double(subject{1}(8:end));
cfg.trl(:,5)=event_code(subject_num);

data_epoch = ft_redefinetrial(cfg, data);

end
