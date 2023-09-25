%%  Step 1: Produce STFTs
function [TF, ts] = SPRiNT_stft(F,opts)
% SPRiNT_stft: Compute a locally averaged short-time Fourier transform (for
% use in SPRiNT)
% 
% Segments of this function were adapted from the Brainstorm software package:
% https://neuroimage.usc.edu/brainstorm
% Tadel et al. (2011) 
% 
% Copyright (c)2000-2020 University of Southern California & McGill University
% This software is distributed under the terms of the GNU General Public License
% as published by the Free Software Foundation. Further details on the GPLv3
% license can be found at http://www.gnu.org/copyleft/gpl.html.
% 
% Author: Luc Wilson (2022)

    sfreq = opts.sfreq;                 % sample rate, in Hertz
    WinLength = opts.WinLength;         % window length, in seconds
    WinOverlap = opts.WinOverlap;       % window overlap, in percent
    avgWin = opts.WinAverage;           % number of windows being averaged per PSD
    nTime = size(F,2);
    % ===== WINDOWING =====
    Lwin  = round(WinLength * sfreq); % number of data points in windows
    Loverlap = round(Lwin * WinOverlap / 100); % number of data points in overlap
    % If window is too small
    if (Lwin < 50)
        return;
    % If window is bigger than the data
    elseif (Lwin > nTime)
        Lwin = size(F,2);
        Lwin = Lwin - mod(Lwin,2); % Make sure the number of samples is even
        Loverlap = 0;
        Nwin = 1;
    % Else: there is at least one full time window
    else
        Lwin = Lwin - mod(Lwin,2);    % Make sure the number of samples is even
        Nwin = floor((nTime - Loverlap) ./ (Lwin - Loverlap));
    end
    % Next power of 2 from length of signal
    NFFT = Lwin;                    % No zero-padding: Nfft = Ntime 
    % Positive frequency bins spanned by FFT
    FreqVector = sfreq / 2 * linspace(0,1,NFFT/2+1);
    % Determine hann window shape/power
    Win = hann(Lwin)';
    WinNoisePowerGain = sum(Win.^2);
    % Initialize STFT,time matrices
    ts = nan(Nwin-(avgWin-1),1);
    TF = nan(size(F,1), Nwin-(avgWin-1), size(FreqVector,2));
    TFtmp = nan(size(F,1), avgWin, size(FreqVector,2));
    % ===== CALCULATE FFT FOR EACH WINDOW =====
    TFfull = zeros(size(F,1),Nwin,size(FreqVector,2));
    for iWin = 1:Nwin
        % Build indices
        iTimes = (1:Lwin) + (iWin-1)*(Lwin - Loverlap);
        center_time = floor(median((iTimes-(avgWin-1)./2*(Lwin - Loverlap))))./sfreq;
        % Select indices
        Fwin = F(:,iTimes);
        % No need to enforce removing DC component (0 frequency).
        Fwin = Fwin - mean(Fwin,2);
        % Apply a Hann window to signal
        Fwin = Fwin .* Win;
        % Compute FFT
        Ffft = fft(Fwin, NFFT, 2);
        % One-sided spectrum (keep only first half)
        % (x2 to recover full power from negative frequencies)
        TFwin = Ffft(:,1:NFFT/2+1) * sqrt(2 ./ (sfreq * WinNoisePowerGain));
        % x2 doesn't apply to DC and Nyquist.
        TFwin(:, [1,end]) = TFwin(:, [1,end]) ./ sqrt(2);
        % Permute dimensions: time and frequency
        TFwin = permute(TFwin, [1 3 2]);
        % Convert to power
        TFwin = abs(TFwin).^2;
        TFfull(:,iWin,:) = TFwin;
        TFtmp(:,mod(iWin,avgWin)+1,:) = TFwin;
        if isnan(TFtmp(1,1,1)) 
            continue % Do not record anything until transient is gone
        else
    %     Save STFTs for window
        TF(:,iWin-(avgWin-1),:) = mean(TFtmp,2);
        ts(iWin-(avgWin-1)) = center_time;
        end
    end
end
