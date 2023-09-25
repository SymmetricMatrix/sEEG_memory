function wavelet_norm_mean = get_seq_wavelet_normalized(read_dir, subject, trials, selected_channel)
% This function loads wavelet data from a specified directory and subject, and normalizes it.
% Inputs:
% - read_dir: the directory where the wavelet data is stored
% - subject: the subject whose data is being analyzed
% - trials: a vector of trial numbers to analyze
% - selected_channel: a vector of channel index
% Output:
% - wavelet_norm_mean: a matrix of normalized wavelet data, with dimensions (timepoints x frequencies x trials)

time = [-1,3.5];
wavelet_norm_mean = [];

for i = 1:length(trials)
    % Load wavelet data
    data_wavelet = load_mat(fullfile(read_dir, subject, 'wavelet', [num2str(trials(i)), '.mat']));
    srate = round(size(data_wavelet.powspctrm,4)/data_wavelet.time(end));
    t0 = data_wavelet.cfg.previous.trialdef.pre*srate;
    
    wavelet = squeeze(data_wavelet.powspctrm(1, selected_channel, :, t0+1+time(1)*srate:t0+time(2)*srate));%%%%%
    
    % Normalize wavelet data
    wavelet_norm = zscore(wavelet, 0, 3);%%%% subject level correct [-1,0]
    
    % Average channels
    wavelet_norm_mean(:, :, i) = mean(wavelet_norm, 1);
end

end