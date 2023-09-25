%%  Step 2: parameterize spectrograms spectra
function [s_data] = SPRiNT_specparam_matlab(TF, fs, opt, ts)
% SPRiNT_specparam_matlab: Compute time-resolved specparam models for
% short-time Fourier transformed signals.
% 
% The spectral parameterization algorithm used herein (specparam) can be 
% cited as:
%   Donoghue, T., Haller, M., Peterson, E.J. et al., Parameterizing neural 
%   power spectra into periodic and aperiodic components. Nat Neurosci 23,
%   1655–1665 (2020). https://doi.org/10.1038/s41593-020-00744-x
%
% Author: Luc Wilson (2022)

    fMask = logical(round(fs.*10)./10 >= round(opt.freq_range(1).*10)./10 & (round(fs.*10)./10 <= round(opt.freq_range(2).*10)./10));
    fs = fs(fMask);
    s_data.Freqs = fs;
    nChan = size(TF,1);
    nTimes = size(TF,2);
    % Adjust TF plots to only include modelled frequencies
    TF = TF(:,:,fMask);
    % Initalize FOOOF structs
    channel(nChan) = struct();
    SPRiNT = struct('options',opt,'freqs',fs,'channel',channel,'SPRiNT_models',nan(size(TF)),'peak_models',nan(size(TF)),'aperiodic_models',nan(size(TF)));
    % Iterate across channels
    for chan = 1:nChan
        channel(chan).data(nTimes) = struct(...
            'time',             [],...
            'aperiodic_params', [],...
            'peak_params',      [],...
            'peak_types',       '',...
            'ap_fit',           [],...
            'fooofed_spectrum', [],...
            'power_spectrum',   [],...
            'peak_fit',         [],...
            'error',            [],...
            'r_squared',        []);
        channel(chan).peaks(nTimes*opt.max_peaks) = struct(...
            'time',             [],...
            'center_frequency', [],...
            'amplitude',        [],...
            'st_dev',           []);
        channel(chan).aperiodics(nTimes) = struct(...
            'time',             [],...
            'offset',           [],...
            'exponent',         []);
        channel(chan).stats(nTimes) = struct(...
            'MSE',              [],...
            'r_squared',        [],...
            'frequency_wise_error', []);
        spec = log10(squeeze(TF(chan,:,:))); % extract log spectra for a given channel
        % Iterate across time
        i = 1; % For peak extraction
        ag = -(spec(1,end)-spec(1,1))./log10(fs(end)./fs(1)); % aperiodic guess initialization
        for time = 1:nTimes
            % Fit aperiodic 
            aperiodic_pars = robust_ap_fit(fs, spec(time,:), opt.aperiodic_mode, ag);
            % Remove aperiodic
            flat_spec = flatten_spectrum(fs, spec(time,:), aperiodic_pars, opt.aperiodic_mode);
            % Fit peaks
            [peak_pars, peak_function] = fit_peaks(fs, flat_spec, opt.max_peaks, opt.peak_threshold, opt.min_peak_height, ...
                opt.peak_width_limits/2, opt.proximity_threshold, opt.peak_type, opt.guess_weight,opt.hOT);
            if opt.thresh_after && ~opt.hOT  % Check thresholding requirements are met for unbounded optimization
                peak_pars(peak_pars(:,2) < opt.min_peak_height,:)     = []; % remove peaks shorter than limit
                peak_pars(peak_pars(:,3) < opt.peak_width_limits(1)/2,:)  = []; % remove peaks narrower than limit
                peak_pars(peak_pars(:,3) > opt.peak_width_limits(2)/2,:)  = []; % remove peaks broader than limit
                peak_pars = drop_peak_cf(peak_pars, opt.proximity_threshold, opt.freq_range); % remove peaks outside frequency limits
                peak_pars(peak_pars(:,1) < 0,:) = []; % remove peaks with a centre frequency less than zero (bypass drop_peak_cf)
                peak_pars = drop_peak_overlap(peak_pars, opt.proximity_threshold); % remove smallest of two peaks fit too closely
            end
            % Refit aperiodic
            aperiodic = spec(time,:);
            for peak = 1:size(peak_pars,1)
                aperiodic = aperiodic - peak_function(fs,peak_pars(peak,1), peak_pars(peak,2), peak_pars(peak,3));
            end
            aperiodic_pars = simple_ap_fit(fs, aperiodic, opt.aperiodic_mode, aperiodic_pars(end));
            ag = aperiodic_pars(end); % save exponent estimate for next iteration
            % Generate model fit
            ap_fit = gen_aperiodic(fs, aperiodic_pars, opt.aperiodic_mode);
            model_fit = ap_fit;
            for peak = 1:size(peak_pars,1)
                model_fit = model_fit + peak_function(fs,peak_pars(peak,1),...
                    peak_pars(peak,2),peak_pars(peak,3));
            end
            % Calculate model error
            MSE = sum((spec(time,:) - model_fit).^2)/length(model_fit);
            rsq_tmp = corrcoef(spec(time,:),model_fit).^2;
            % Return FOOOF results
            aperiodic_pars(2) = abs(aperiodic_pars(2));
            channel(chan).data(time).time                = ts(time);
            channel(chan).data(time).aperiodic_params    = aperiodic_pars;
            channel(chan).data(time).peak_params         = peak_pars;
            channel(chan).data(time).peak_types          = func2str(peak_function);
            channel(chan).data(time).ap_fit              = 10.^ap_fit;
            aperiodic_models(chan,time,:)                = 10.^ap_fit;
            channel(chan).data(time).fooofed_spectrum    = 10.^model_fit;
            SPRiNT_models(chan,time,:)                   = 10.^model_fit;
            channel(chan).data(time).power_spectrum   	 = 10.^spec(time,:);
            channel(chan).data(time).peak_fit            = 10.^(model_fit-ap_fit); 
            peak_models(chan,time,:)                     = 10.^(model_fit-ap_fit); 
            channel(chan).data(time).error               = MSE;
            channel(chan).data(time).r_squared           = rsq_tmp(2);
            % Extract peaks
            if ~isempty(peak_pars) & any(peak_pars)
                for p = 1:size(peak_pars,1)
                    channel(chan).peaks(i).time = ts(time);
                    channel(chan).peaks(i).center_frequency = peak_pars(p,1);
                    channel(chan).peaks(i).amplitude = peak_pars(p,2);
                    channel(chan).peaks(i).st_dev = peak_pars(p,3);
                    i = i +1;
                end
            end
            % Extract aperiodic
            channel(chan).aperiodics(time).time = ts(time);
            channel(chan).aperiodics(time).offset = aperiodic_pars(1);
            if length(aperiodic_pars)>2 % Legacy specparam alters order of parameters
                channel(chan).aperiodics(time).exponent = aperiodic_pars(3);
                channel(chan).aperiodics(time).knee_frequency = aperiodic_pars(2);
            else
                channel(chan).aperiodics(time).exponent = aperiodic_pars(2);
            end
            channel(chan).stats(time).MSE = MSE;
            channel(chan).stats(time).r_squared = rsq_tmp(2);
            channel(chan).stats(time).frequency_wise_error = abs(spec(time,:)-model_fit);
        end
        channel(chan).peaks(i:end) = [];
    end
    SPRiNT.channel = channel;
    SPRiNT.aperiodic_models = aperiodic_models;
    SPRiNT.SPRiNT_models = SPRiNT_models;
    SPRiNT.peak_models = peak_models;
    if strcmp(opt.rmoutliers,'yes')
        SPRiNT = remove_outliers(SPRiNT,peak_function,opt);
    end
    SPRiNT = cluster_peaks_dynamic2(SPRiNT); % Cluster peaks
    s_data.SPRiNT = SPRiNT;
end