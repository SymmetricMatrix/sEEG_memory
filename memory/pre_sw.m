function data_norm = pre_sw(data, old_sample_rate)
% This function performs several operations on the input data to normalize it.
%
% Inputs:
%   data: matrix format data, channel*frex*time, from squeeze(data_wavelet.powspctrm)
%   old_sample_rate: sample rate for data
%
% Outputs:
%   data_norm: matrix format data, chan*frex*time

% Check input
if length(size(data)) ~= 3
    error('Input data should be 3 dimensions, such as: channel*frex*time');
end

% Get the number of frequencies and channels from the data
freq = size(data, 2);
chan = size(data, 1);

% Downsample the data to a new sample rate of 1000
new_sample_rate = 1000;
time = size(data, 3) / old_sample_rate;

% Slide window parameters
window_size = 50; % window size in ms
step = 10; % step size in ms
sample_per_win = round(window_size / 1000 * new_sample_rate); % number of samples per window
half_win = sample_per_win / 2;
step_per_win = round(step / 1000 * new_sample_rate); % number of samples per step

new_time_point = round(time * new_sample_rate / step_per_win);

% Perform downsampling and sliding window operation
data_ds_sw = zeros(chan, freq, new_time_point);
for freqi = 1:freq
    % Downsample the data
    data_down = resample(squeeze(data(:, freqi, :))', new_sample_rate, old_sample_rate)';

    % Padding
    data_down = [nan(size(data_down, 1), half_win), data_down, nan(size(data_down, 1), half_win)];

    % Slide windows
    win_idx = half_win + 10:step:size(data_down, 2) - half_win;
    if new_time_point ~= length(win_idx)
        error('Something went wrong');
    end

    for timei = 1:length(win_idx)
        data_ds_sw(:, freqi, timei) = nanmean(data_down(:, win_idx(timei) - half_win:win_idx(timei) + half_win - 1), 2);
    end
end

% Combine frequencies into 46 bands
frex = 46;
data_swa = zeros(chan, frex, new_time_point);
data_swa(:, 1:28, :) = data_ds_sw(:, 2:29, :);
for k = 1:18
    data_swa(:, 28 + k, :) = nanmean(data_ds_sw(:, 25 + k * 5:29 + k * 5, :), 2);
end

% Normalize the data using z-score for each channel and each frequency
data_norm = zeros(size(data_swa));
for frei = 1:size(data_swa, 2)
    for chani = 1:size(data_swa, 1)
        data_set = data_swa(chani, frei, :);
        data_norm(chani, frei, :) = (data_set - nanmean(data_set)) ./ nanstd(data_set);
    end
end
end

