function seeg_pre(sub_id, proj, home_dir, save_dir, ele_excl)
% This function preprocesses SEEG data for object_recognition/sequence_memory analysis.
% It includes filtering, bipolar referencing, epoching, wavelet analysis,
% and a sliding window approach.
%
% Inputs:
% sub_id - the subject ID
% proj - project name, 'object_recognition' or 'sequence_memory'
% home_dir - the directory where the SEEG data is stored
% save_dir - the directory where processed data is stored
% ele_excl - a table of electrode labels to exclude
%
% Outputs:
% None (data is saved to disk)
%
% Related functions:
% pre_filter, pre_epoch, pre_sw

%% Parameter setting
switch proj
    case 'object_recognition'
        sw_time = [151:350]; % original [-2,3], save [-0.5,1.5]
    case 'sequence_memory'
        sw_time = [251:1000]; % original [-5,7], save [-2.5,5]
end

subject = strcat('subject', num2str(sub_id));
sub_dir = dir(fullfile([home_dir,'subject/', subject, '/seeg_edf/', proj], '*.edf'));

disp(subject)

%% preprocess,
% contains the following steps:
% 1. change edf label name
% 2. filter
% 3. bipolar
% 4. epoch
% 5. wavelet and slide window

tic
if ~isempty(sub_dir)
    read_dir = [sub_dir.folder, '/', sub_dir.name];
    
    % change edf label name, filter & bipolar
    channels = table2cell(ele_excl(ele_excl.sub_id == sub_id & ele_excl.lab_inside == 1, {'label'}));
    channels_bs = table2cell(ele_excl(ele_excl.sub_id == sub_id & ele_excl.lab_inside == 1, {'lab_bs'}));
    
    data_pre = pre_filter(read_dir, channels, channels_bs);
    channel = data_pre.label;
    save([save_dir, subject, '_pre.mat'], 'data_pre', '-v7.3');
    save([save_dir, subject, '_channel.mat'], 'channel', '-v7.3');
    
    % Epoch
    % Need trigger_new.mat, trigger.mat
    data_epoch = pre_epoch(save_dir, subject, data_pre,proj);
    save([save_dir, subject, '_epoch.mat'], 'data_epoch', '-v7.3');
    
    trial_num = num2str(size(data_epoch.trial, 2));
    label_num = num2str(length(data_epoch.label));
    srate = num2str(data_epoch.fsample);
    disp('1. Preprocess done')
    disp(['samplerate: ', srate, ';  trial number: ', trial_num, ';  label_num:', label_num])
    toc
    
    %% Wavelet & Sliding window approach
    h = waitbar(0, 'Wavelet trial...'); % Create progress bar
    trial_num = length(data_epoch.trial);
    mkdir([save_dir, 'wavelet'])
    data_sw = [];
    
    for triali = 1:trial_num % Reduce storage space
        waitbar(triali / trial_num, h, sprintf('Wavelet trial: %d / %d', triali, trial_num)); % Update progress bar
        
        % Wavelet analysis
        cfg = [];
        cfg.method = 'wavelet';
        cfg.pad = 'nextpow2';
        cfg.output = 'pow';
        cfg.channel = 'all';
        cfg.trials = triali;
        cfg.keeptrials = 'yes';
        cfg.width = 6;  %
        cfg.toi = 'all';
        cfg.foi = 1:120;  %
        data_wavelet = ft_freqanalysis(cfg, data_epoch);
        save([save_dir, 'wavelet', '/', num2str(triali), '.mat'], 'data_wavelet', '-v7.3');
        
        data_sw_temp = pre_sw(squeeze(data_wavelet.powspctrm), data_epoch.hdr.Fs);
        data_sw(:, :, :, triali) = data_sw_temp(:, :, sw_time); % channnel*frex*time*trails
    end
    save([save_dir, '/', subject, '_sw.mat'], 'data_sw', '-v7.3');
    close(h); % Close progress bar
    disp('2. Wavelet & Sliding window done')
else
    disp('No such file')
end
end