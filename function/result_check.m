% result_chaeck
%% pointing
subject=[1:18];
read_dir = '/bigvault/Projects/seeg_pointing/results/3dpointing/';
result=[];
k=1;
for i=subject
    files = dir(fullfile(read_dir, ['subject', num2str(i)], '*.mat'));
    for j=1:size(files,1)
        file = [files(j).folder,'/',files(j).name];
        fileInfo = dir(file);
        if size(fileInfo,1)~=0
            name = fileInfo.name;
            Time = fileInfo.date;
            
            matObj = matfile(file);
            
            result{k,1}=i;
            result{k,2}=name;
            result{k,3}=Time;
            result{k,4}=whos(matObj).name;
            result{k,5}=size(matObj,whos(matObj).name);
            k=k+1;
        end
    end
end
%% object
subject=[1:18];
read_dir = '/bigvault/Projects/seeg_pointing/results/object_recognition/';
result=[];
k=1;
for i=subject
    files = dir(fullfile(read_dir, ['subject', num2str(i)], '*.mat'));
    for j=1:size(files,1)
        file = [files(j).folder,'/',files(j).name];
        fileInfo = dir(file);
        if size(fileInfo,1)~=0
            name = fileInfo.name;
            Time = fileInfo.date;
            
            matObj = matfile(file);
            
            result{k,1}=i;
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
for i=subject
    files = dir(fullfile(read_dir, ['subject', num2str(i)], '*.mat'));
    for j=1:size(files,1)
        file = [files(j).folder,'/',files(j).name];
        fileInfo = dir(file);
        if size(fileInfo,1)~=0
            name = fileInfo.name;
            Time = fileInfo.date;
            
            matObj = matfile(file);
            
            result{k,1}=i;
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