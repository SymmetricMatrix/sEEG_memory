function [trl, event] = ft_trialfun_edf(cfg)

% FT_TRIALFUN_EDF is an example trial function for EDF data. It searches for events
% of type "up" in an analog data channel, as indentified by thresholding. This
% threshold can be a hard threshold, i.e. a numeric, or can flexibly be defined
% depending on the data, for example calculating the 'median' of an analog signal.
%
% You can use this as a template for your own conditial trial definitions.
%
% Use this function by calling 
%   [cfg] = ft_definetrial(cfg)
% where the configuration structure should contain
%   cfg.dataset  = string with the filename
%   cfg.trialfun = 'ft_trialfun_edf'
%
% See also FT_DEFINETRIAL, FT_TRIALFUN_GENERAL

% read the header information

hdr           = ft_read_header(cfg.dataset);

% read the events from the data
chanindx      = find(strcmp(hdr.label,'TRIG'));%cfg.chanindx; % this should be adapted to your data
detectflank   = 'up';
threshold     = cfg.threshold; % or, e.g., 1/2 times the median for down flanks
event         = ft_read_event(cfg.dataset, 'chanindx', chanindx, 'detectflank', detectflank, 'threshold', threshold);

trigger = ft_read_data(cfg.dataset);

% define trials around the events
trl           = [];
pretrig       = cfg.trialdef.pre * hdr.Fs; % e.g., 1 sec before trigger
posttrig      = cfg.trialdef.post * hdr.Fs; % e.g., 2 sec after trigger
for i = 1:numel(event)
  offset    = -hdr.nSamplesPre;  % number of samples prior to the trigger
  trlbegin  = event(i).sample - pretrig;
  trlend    = event(i).sample + posttrig;
  value     = trigger(event(i).sample);
  newtrl    = [trlbegin trlend offset value];
  trl       = [trl; newtrl]; % store in the trl matrix
end
end