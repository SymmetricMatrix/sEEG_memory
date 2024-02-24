cfg = [];
cfg.method = 'convert';
cfg.datatype  = 'eeg';

% specify the input file name, here we are using the same file for every subject
%cfg.dataset   = 'subject1_epoch.mat';

% specify the output directory
cfg.bidsroot  = 'bids';
cfg.sub       = '01';

% specify the information for the participants.tsv file
% this is optional, you can also pass other pieces of info
cfg.participants.age = '17';
cfg.participants.sex = 'm';

% specify the information for the scans.tsv file
% this is optional, you can also pass other pieces of info
cfg.scans.acq_time = datestr(now, 'yyyy-mm-ddThh:MM:SS'); % according to RFC3339

% specify some general information that will be added to the eeg.json file
cfg.InstitutionName             = 'Zhejiang University';
cfg.InstitutionalDepartmentName = 'Department of Psychological and Behavioral Sciences';
cfg.InstitutionAddress          = 'Yuhangtang Rd 866, 310058 Hangzhou, Zhejiang, China';

% provide the mnemonic and long description of the task
cfg.TaskName        = 'memory';
cfg.TaskDescription = 'Subjects were responding as fast as possible upon a change in a visually presented stimulus.';

% these are EEG specific
cfg.eeg.PowerLineFrequency = 60;   % since recorded in the USA
cfg.eeg.EEGReference       = 'M1'; % actually I do not know, but let's assume it was left mastoid

data2bids(cfg,data_epoch);