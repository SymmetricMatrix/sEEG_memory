function data_epoch = pre_epoch(read_dir,subject, data, proj)
% This function reads in pre-processed data and epochs it based on the project type.
%
% Inputs:
%   read_dir: File path
%   data: FieldTrip format data, the pre-processed data
%   proj: Project type ('object_recognition' or 'sequence_memory')
%
% Outputs:
%   data_epoch: FieldTrip format data, the epoch data

% Dependent function: 
%    event_code.m
    
% modification time: 20230813


cfg = [];
sub_id = str2double(subject(8:end));
% Define the epoch duration based on the project type
if strcmp(proj, 'object_recognition')
    epoch_duration = [3, 4.5];
elseif strcmp(proj, 'sequence_memory')
    epoch_duration = [5.5,8];
else
    error('Invalid project type');
end

% Define the epoch configuration

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

% Epoch the data
data_epoch = ft_redefinetrial(cfg, data);

end