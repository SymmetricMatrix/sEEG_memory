function save_seq_cfg(subject)
% save sequence cfg(mainly trl) for  pic_pair_obj2seq
epoch_duration = [5.5,8];
cfg = [];
read_dir = fullfile('/bigvault/Projects/seeg_pointing/results/sequence_memory',subject);
cfg.dataset = fullfile(read_dir, 'trigger.mat');
cfg.trialfun = 'ft_trialfun_edf';
cfg.trialdef.pre = epoch_duration(1);
cfg.trialdef.post = epoch_duration(2);
cfg.threshold = 7;
cfg = ft_definetrial(cfg);


% Define the event codes based on the subject number
sub_id = str2num(subject(8:end));
cfg.trl(:, 5) = event_code(sub_id);


save(fullfile(read_dir, [subject, '_cfg.mat']), 'cfg', '-v7.3');
end