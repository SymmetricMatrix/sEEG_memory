function  data_pre=pre_filter(read_dir,channels,channels_bs)
% preprocess rereference, band pass filter, nortch filter
% will save the file

%%
% read edf and replace channels
cfg            = [];
cfg.dataset    = read_dir;
cfg.channel    = channels;
data = ft_preprocessing(cfg);
data.hdr.labeledf=data.label;
data.label=channels_bs;

% biploar
cfg            = [];
cfg.reref      = 'yes';
cfg.refmethod  = 'bipolar';
cfg.refchannel = 'all';
cfg.groupchans = 'yes';

% filter
cfg.bpfilter       = 'yes';
cfg.bpfreq         = [0.1 250];
cfg.bsfilter       = 'yes';
cfg.bpfiltord      = 3;
cfg.bsfreq         = [49 51; 99 101; 149 151; 199 201; 149 250];

data_pre = ft_preprocessing(cfg,data);

end

