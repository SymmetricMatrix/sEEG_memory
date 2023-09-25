%% Raw LEMON dataset
% preprocesses RAW LEMON dataset 
% 1. import data
% 2. ADD EEG positions
% 3. Resample EEG 250 Hz
% 4. High-pass
% 5. Make PSD to verify quality 
cd('/Volumes/Seagate Portable Drive/LEMON/ftp.gwdg.de/pub/misc/MPI-Leipzig_Mind-Brain-Body-LEMON/EEG_MPILMBB_LEMON/EEG_Raw_BIDS_ID')

files_EO=dir('sub*/RSEEG/sub*.eeg');

sFiles = [];
nsubj= 50; 

firstSubject = 151;
lastSubject = 203;

% make subject names
for i = firstSubject:lastSubject
    db_reload_database('current');
    subjectname{i} = files_EO(i,1).name(1:10);
    [sSubject{i}, iSubject] = db_add_subject(subjectname{i});
    
end
      
db_reload_database('current');
   
for i = firstSubject:lastSubject
    % Process: Create link to raw file
sFiles = bst_process('CallProcess', 'process_import_data_raw', sFiles, [], ...
    'subjectname',    subjectname{i}, ...
    'datafile',      {strcat(files_EO(i,1).folder, '/', files_EO(i,1).name), 'EEG-BRAINAMP'} , ...
    'evtmode',        'value');
    

% Process: Add EEG positions
sFiles = bst_process('CallProcess', 'process_channel_addloc', sFiles, [], ...
    'channelfile', {'', ''}, ...
    'usedefault',  23, ...  % Colin27: BrainProducts EasyCap 64
    'fixunits',    1, ...
    'vox2ras',     1);

% Process: Resample: 250Hz
sFiles = bst_process('CallProcess', 'process_resample', sFiles, [], ...
    'freq',     250, ...
    'read_all', 0);

% Process: High-pass:0.1Hz
sFiles = bst_process('CallProcess', 'process_bandpass', sFiles, [], ...
    'sensortypes', ' EEG', ...
    'highpass',    0.1, ...
    'lowpass',     0, ...
    'tranband',    0, ...
    'attenuation', 'strict', ...  % 60dB
    'ver',         '2019', ...  % 2019
    'mirror',      0, ...
    'read_all',    0);

% Process: Power spectrum density (Welch)
sFiles = bst_process('CallProcess', 'process_psd', sFiles, [], ...
    'timewindow',  [], ...
    'win_length',  1, ...
    'win_overlap', 50, ...
    'units',       'physical', ...  % Physical: U2/Hz
    'sensortypes', 'EEG', ...
    'win_std',     0, ...
    'edit',        struct(...
         'Comment',         'Power', ...
         'TimeBands',       [], ...
         'Freqs',           [], ...
         'ClusterFuncTime', 'none', ...
         'Measure',         'power', ...
         'Output',          'all', ...
         'SaveKernel',      0));


end

% TO DO MANUALLY 
% identify the bad channels
% SSP

