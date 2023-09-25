% result_chaeck
%% pointing
read_dir = '/bigvault/Projects/seeg_pointing/results/seed/sequence_memory';
result=[];
k=1;
for sub_id=1:27
    subject = ['subject', num2str(sub_id)];
    files = dir(fullfile(read_dir, subject, [subject,'_fixation*.mat']));
    
    for j=1:size(files,1)
        file = [files(j).folder,'/',files(j).name];
        fileInfo = dir(file);
        if size(fileInfo,1)~=0
            name = fileInfo.name;
            Time = fileInfo.date;
            load(file)
            
            matObj = matfile(file);
            
            result{k,1}=sub_id;
            result{k,2}=name;
            result{k,3}=Time;
            result{k,4}=whos(matObj).name;
            result{k,5}=size(matObj,whos(matObj).name);
            result{k,6}=any(any(any(isnan(data_fixation))));% 0 means no Nan
            k=k+1;
        end
    end
end
%% object
subject=[1:18];
read_dir = '/bigvault/Projects/seeg_pointing/results/object_recognition/';
result=[];
k=1;
for sub_id=subject
    files = dir(fullfile(read_dir, ['subject', num2str(sub_id)], '*.mat'));
    for j=1:size(files,1)
        file = [files(j).folder,'/',files(j).name];
        fileInfo = dir(file);
        if size(fileInfo,1)~=0
            name = fileInfo.name;
            Time = fileInfo.date;
            
            matObj = matfile(file);
            
            result{k,1}=sub_id;
            result{k,2}=name;
            result{k,3}=Time;
            result{k,4}=whos(matObj).name;
            result{k,5}=size(matObj,whos(matObj).name);
            k=k+1;
        end
    end
end

%% sequence
subject=[1:18];
read_dir = '/bigvault/Projects/seeg_pointing/results/sequence_memory/';
result=[];
k=1;
for sub_id=subject
    files = dir(fullfile(read_dir, ['subject', num2str(sub_id)], '*.mat'));
    for j=1:size(files,1)
        file = [files(j).folder,'/',files(j).name];
        fileInfo = dir(file);
        if size(fileInfo,1)~=0
            name = fileInfo.name;
            Time = fileInfo.date;
            
            matObj = matfile(file);
            
            result{k,1}=sub_id;
            result{k,2}=name;
            result{k,3}=Time;
            result{k,4}=whos(matObj).name;
            result{k,5}=size(matObj,whos(matObj).name);
            k=k+1;
        end
    end
end
%% check  event numbers
proj = 'object_recognition';
%proj = 'sequence_memory';
save_dir = ['/bigvault/Projects/seeg_pointing/results/',proj,'/'];
threshold = 7;
event=[];
for sub_id=1:18
    subject = strcat('subject', num2str(sub_id));
    
    try
        read_dir=[save_dir,subject];
        load( fullfile(read_dir, 'trigger.mat'))
        
        % epoch
        cfg = [];
        cfg.dataset = fullfile(read_dir, 'trigger.mat');
        cfg.trialfun = 'ft_trialfun_edf';
        cfg.trialdef.pre  = 5;
        cfg.trialdef.post = 7;
        cfg.threshold = threshold;
        cfg = ft_definetrial(cfg);
        
        event{sub_id,1}=sub_id;
        event{sub_id,2}=size(cfg.trl);
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end
%% object load epoch check events
proj = 'object_recognition';
save_dir = ['/bigvault/Projects/seeg_pointing/results/',proj,'/'];
epoch=[];
for sub_id=1:18
    subject = strcat('subject', num2str(sub_id));
    
    try
        read_dir=[save_dir,subject];
        load( fullfile(read_dir,[subject,'_epoch.mat']))
        
        % epoch
        epoch{sub_id,1}=sub_id;
        epoch{sub_id,2}=data_epoch.label;
        epoch{sub_id,3}=data_epoch.cfg.trl;
        epoch{sub_id,4}=data_epoch.sampleinfo;
        epoch{sub_id,5}=data_epoch.hdr.Fs;
        epoch{sub_id,6}=size(data_epoch.cfg.trl,1);
        epoch{sub_id,7}=data_epoch.hdr.orig.FileName;
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end
%% sequence load epoch check events
proj = 'object_recognition';
%proj = 'sequence_memory';
save_dir = ['/bigvault/Projects/seeg_pointing/results/',proj,'/'];
epoch=[];
for sub_id=1:18
    subject = strcat('subject', num2str(sub_id));
    
    try
        read_dir=[save_dir,subject];
        load( fullfile(read_dir,[subject,'_epoch.mat']))
        
        % epoch
        epoch{sub_id,1}=sub_id;
        epoch{sub_id,2}=data_epoch.label;
        epoch{sub_id,3}=data_epoch.trialinfo;
        epoch{sub_id,4}=data_epoch.sampleinfo;
        epoch{sub_id,5}=data_epoch.hdr.Fs;
        epoch{sub_id,6}=size(data_epoch.trialinfo,1);
        epoch{sub_id,7}=data_epoch.hdr.orig.FileName;
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end
%% srate
proj = '3dpointing';
proj_dir = '/bigvault/Projects/seeg_pointing/subject/';
summary=[];
for sub_id=1:27
    subject = strcat('subject', num2str(sub_id));
    sub_dir =dir(fullfile([proj_dir, subject, '/seeg_edf/', proj], '*.edf'));
    try
        read_dir = [sub_dir.folder, '/', sub_dir.name];
        header = ft_read_header(read_dir);
        srate = header.Fs;
        
        summary{sub_id,1}=sub_id;
        summary{sub_id,2}=srate;
        
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end
%%% result_chaeck
%% pointing
read_dir = '/bigvault/Projects/seeg_pointing/results/seed/sequence_memory';
result=[];
k=1;
for sub_id=1:27
    subject = ['subject', num2str(sub_id)];
    files = dir(fullfile(read_dir, subject, [subject,'_fixation*.mat']));
    
    for j=1:size(files,1)
        file = [files(j).folder,'/',files(j).name];
        fileInfo = dir(file);
        if size(fileInfo,1)~=0
            name = fileInfo.name;
            Time = fileInfo.date;
            load(file)
            
            matObj = matfile(file);
            
            result{k,1}=sub_id;
            result{k,2}=name;
            result{k,3}=Time;
            result{k,4}=whos(matObj).name;
            result{k,5}=size(matObj,whos(matObj).name);
            result{k,6}=any(any(any(isnan(data_fixation))));% 0 means no Nan
            k=k+1;
        end
    end
end
%% object
subject=[1:18];
read_dir = '/bigvault/Projects/seeg_pointing/results/object_recognition/';
result=[];
k=1;
for sub_id=subject
    files = dir(fullfile(read_dir, ['subject', num2str(sub_id)], '*.mat'));
    for j=1:size(files,1)
        file = [files(j).folder,'/',files(j).name];
        fileInfo = dir(file);
        if size(fileInfo,1)~=0
            name = fileInfo.name;
            Time = fileInfo.date;
            
            matObj = matfile(file);
            
            result{k,1}=sub_id;
            result{k,2}=name;
            result{k,3}=Time;
            result{k,4}=whos(matObj).name;
            result{k,5}=size(matObj,whos(matObj).name);
            k=k+1;
        end
    end
end

%% sequence
subject=[1:18];
read_dir = '/bigvault/Projects/seeg_pointing/results/sequence_memory/';
result=[];
k=1;
for sub_id=subject
    files = dir(fullfile(read_dir, ['subject', num2str(sub_id)], '*.mat'));
    for j=1:size(files,1)
        file = [files(j).folder,'/',files(j).name];
        fileInfo = dir(file);
        if size(fileInfo,1)~=0
            name = fileInfo.name;
            Time = fileInfo.date;
            
            matObj = matfile(file);
            
            result{k,1}=sub_id;
            result{k,2}=name;
            result{k,3}=Time;
            result{k,4}=whos(matObj).name;
            result{k,5}=size(matObj,whos(matObj).name);
            k=k+1;
        end
    end
end
%% check  event numbers
proj = 'object_recognition';
%proj = 'sequence_memory';
save_dir = ['/bigvault/Projects/seeg_pointing/results/',proj,'/'];
threshold = 7;
event=[];
for sub_id=1:18
    subject = strcat('subject', num2str(sub_id));
    
    try
        read_dir=[save_dir,subject];
        load( fullfile(read_dir, 'trigger.mat'))
        
        % epoch
        cfg = [];
        cfg.dataset = fullfile(read_dir, 'trigger.mat');
        cfg.trialfun = 'ft_trialfun_edf';
        cfg.trialdef.pre  = 5;
        cfg.trialdef.post = 7;
        cfg.threshold = threshold;
        cfg = ft_definetrial(cfg);
        
        event{sub_id,1}=sub_id;
        event{sub_id,2}=size(cfg.trl);
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end
%% object load epoch check events
proj = 'object_recognition';
save_dir = ['/bigvault/Projects/seeg_pointing/results/',proj,'/'];
epoch=[];
for sub_id=1:18
    subject = strcat('subject', num2str(sub_id));
    
    try
        read_dir=[save_dir,subject];
        load( fullfile(read_dir,[subject,'_epoch.mat']))
        
        % epoch
        epoch{sub_id,1}=sub_id;
        epoch{sub_id,2}=data_epoch.label;
        epoch{sub_id,3}=data_epoch.cfg.trl;
        epoch{sub_id,4}=data_epoch.sampleinfo;
        epoch{sub_id,5}=data_epoch.hdr.Fs;
        epoch{sub_id,6}=size(data_epoch.cfg.trl,1);
        epoch{sub_id,7}=data_epoch.hdr.orig.FileName;
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end
%% sequence load epoch check events
proj = 'object_recognition';
%proj = 'sequence_memory';
save_dir = ['/bigvault/Projects/seeg_pointing/results/',proj,'/'];
epoch=[];
for sub_id=1:18
    subject = strcat('subject', num2str(sub_id));
    
    try
        read_dir=[save_dir,subject];
        load( fullfile(read_dir,[subject,'_epoch.mat']))
        
        % epoch
        epoch{sub_id,1}=sub_id;
        epoch{sub_id,2}=data_epoch.label;
        epoch{sub_id,3}=data_epoch.trialinfo;
        epoch{sub_id,4}=data_epoch.sampleinfo;
        epoch{sub_id,5}=data_epoch.hdr.Fs;
        epoch{sub_id,6}=size(data_epoch.trialinfo,1);
        epoch{sub_id,7}=data_epoch.hdr.orig.FileName;
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end
%% wavelet 2 data_sw and data_fixation
proj = 'sequence_memory';
proj_dir = ['/bigvault/Projects/seeg_pointing/results/seed/',proj,'/'];
time_sw = [301:1050]; % original [-5.5,8], save [-2.5,5]
time_fixation = [450,550];
epoch=[];
for sub_id=[1,9,19,25]
    subject = strcat('subject', num2str(sub_id));
    
    try
        read_dir=[proj_dir,subject,'/wavelet/'];
        save_dir=[proj_dir,subject,'/'];
        
        h = waitbar(0, 'Wavelet trial...'); % Create progress bar
        
        load([save_dir,'trigger.mat'])
        srate = data_trigger.fsample;
        trial_num = length(dir(read_dir))-2;
        
        data_sw = [];
        data_fixation = [];
        for triali = 1:trial_num
             waitbar(triali / trial_num, h, sprintf('Wavelet trial: %d / %d', triali, trial_num)); % Update progress bar
            load([read_dir,num2str(triali),'.mat'])
            data_sw_temp = pre_sw(squeeze(data_wavelet.powspctrm), srate);
            data_sw(:, :, :, triali) = data_sw_temp(:, :, time_sw); % channnel*frex*time*trails
            fixation_idx = time_fixation(1)/100*srate+1:time_fixation(2)/100*srate;
            data_fixation(:,:,triali) = squeeze(mean(data_wavelet.powspctrm(:,:,:,fixation_idx),4));
        end
        save([save_dir, subject, '_sw.mat'], 'data_sw', '-v7.3');
        save([save_dir, subject, '_fixation.mat'], 'data_fixation', '-v7.3');
        close(h); % Close progress bar
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end

