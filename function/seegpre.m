function  data_pre=seegpre(read_dir,channels,channels_bs)
% preprocess including: rereference, band pass filter, nortch filter

% input 
%     read_dir     -- dir for edf dataset
%     channels     -- channels select for further analyse
%     channels_bs  -- channel name in barainstorm, to correct the label
%                     name in edf

% output
%     data_pre     -- fieldtrip format data,The pre-processed data

% modification time: 20230715

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

