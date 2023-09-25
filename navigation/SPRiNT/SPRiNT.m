%% SPRiNT (without Brainstorm)
function  s_data = SPRiNT(F,opt_new)
                            % Input time series
% STFT opts
opt.sfreq = 200;                    % Input sampling rate
opt.WinLength = 1;                  % STFT window length
opt.WinOverlap = 50;                % Overlap between sliding windows (in %)
opt.WinAverage = 5;                 % Number of sliding windows averaged by time point
% specparam opts
opt.freq_range          = [1 40];
opt.peak_width_limits   = [1.5 6];
opt.max_peaks           = 3;
opt.min_peak_height     = 6 / 10; % convert from dB to B
opt.aperiodic_mode      = 'fixed'; % alternative: knee
opt.peak_threshold      = 2.0;   % 2 std dev: parameter for interface simplification
% Matlab-only options
opt.peak_type           = 'gaussian'; % alternative: cauchy
opt.proximity_threshold = 2;
opt.guess_weight        = 'none';
opt.thresh_after        = true;   % Threshold after fitting, always selected for Matlab 
                                  % (mirrors the Python FOOOF closest by removing peaks
                                  % that do not satisfy a user's predetermined conditions)
                                  % only used in the absence of the
if license('test','optimization_toolbox') % check for optimization toolbox
    opt.hOT = 1;
    disp('Using constrained optimization, Guess Weight ignored.')
else
    opt.hOT = 0;
    disp('Using unconstrained optimization, with Guess Weights.')
end
opt.rmoutliers          = 'yes';
opt.maxfreq             = 2.5;
opt.maxtime             = 6;
opt.minnear             = 3;  


% updata opt with changed parameter
if ~isempty(opt_new)
    opt=catstruct(opt,opt_new);
end


Freqs = 0:1/opt.WinLength:opt.sfreq/2;
channel = struct('data',[],'peaks',[],'aperiodics',[],'stats',[]);
% Compute short-time Fourier transform
[TF, ts] = SPRiNT_stft(F,opt);
outputStruct = struct('opts',opt,'freqs',Freqs,'channel',channel);
% Parameterize STFTs
s_data = SPRiNT_specparam_matlab(TF,outputStruct.freqs,outputStruct.opts,ts);
end