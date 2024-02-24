% This code mainly about extract wavelet data in single brain,this mainly
% about two methd:
% 1. extract data direct from each subject's wavlet data
% 2. extract each subject's raw seeg data then caculate wavelet
% 
%  the criteria of contact belongs to a brain region
clc
clear
%% check data in specific brain
label_table = readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/contacts.csv');
brain_region= 'Hippocampus';
channels_selected = table2cell(label_table(contains(label_table.AAL3, brain_region) , {'sub_id'}));
tabulate(cell2mat(channels_selected))
save_dir='/bigvault/Projects/seeg_pointing/results/memory_group/';

%% Methed 1, wavelet data
% extract wavelet result for single subject 
label_table = readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/contacts.csv');
read_dir = '/bigvault/Projects/seeg_pointing/results/sequence_memory/';
brain_region= 'Hippocampus';
data_type = 'wavelet';

% caculate normalized wavelet data for each subject
for sub_id = 1
    subject = ['subject',num2str(sub_id)];
    disp([subject,'  start'])
    try
        tic
        wavelet_dir = fullfile(read_dir, subject, 'wavelet');
        trial_select = 1:length(dir(wavelet_dir))-2;
        % read wavelet for each subject, Specify trials
        [data_selected, data_fixation, selected_info] = get_seeg_in_brain_region(subject, brain_region, data_type, read_dir, label_table,trial_select);
        
        if ~isempty(data_selected)
            save(fullfile(read_dir,subject,[brain_region,'_wavelet.mat']),'data_selected','-v7.3') % chan * freq* time* trials
            save(fullfile(read_dir,subject,[brain_region,'_fixation.mat']),'data_fixation','-v7.3') % chan * freq* time* trials
            save(fullfile(read_dir,subject,[brain_region,'_selected_info.mat']),'selected_info','-v7.3')
            
            % data normalize
            data_selected_normalized = [];
            data_fixation_mean = mean(data_fixation,3);
            for chani =1:size(data_fixation_mean,1)
                for freqi =1:size(data_fixation_mean,2)
                    data_selected_normalized(chani,freqi,:,:) = (data_selected(chani,freqi,:,:)-data_fixation_mean(chani,freqi))/data_fixation_mean(chani,freqi);
                end
            end
            save(fullfile(read_dir,subject,[brain_region,'_wavelet_normalized.mat']),'data_selected_normalized','-v7.3')
        end
        toc
        
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end

% kurtosis for single subject
read_dir = '/bigvault/Projects/seeg_pointing/results/sequence_memory/';
brain_region= 'Hippocampus';
kurt_group =[];
for sub_id = 1:27
    subject = ['subject',num2str(sub_id)];
    disp([subject])
    try
        kurt=[];
        data_epoch  = load_mat(fullfile(read_dir,subject,[subject,'_epoch.mat']));
        selected_info = load_mat(fullfile(read_dir,subject,[brain_region,'_selected_info.mat']));
        for triali =1:length(data_epoch.trial)
            kurt(:,triali) = kurtosis(data_epoch.trial{1, triali}(selected_info.position,:)');
        end
        selected_info.kurt = kurt;
        kurt_group = [kurt_group;kurt(:,end-215:end)];
        save(fullfile(read_dir,subject,[brain_region,'_selected_info.mat']),'selected_info','-v7.3')
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end

% merge wavelet group each chnanel
read_dir = '/bigvault/Projects/seeg_pointing/results/sequence_memory/';
brain_region= 'Hippocampus';
info_group = [];
kurt_group = [];
wavelet_channel = [];
data_bd_group = [];
data_non_bd_group = [];

for sub_id = 10
    subject = ['subject',num2str(sub_id)];
    disp([subject])
    try
        data_cell = [];
        data_bd =  [];
        data_non_bd = [];
        data_selected_normalized  = load_mat(fullfile(read_dir,subject,[brain_region,'_wavelet_normalized.mat']));
        selected_info = load_mat(fullfile(read_dir,subject,[brain_region,'_selected_info.mat']));
        position = selected_info.position;
        info =[ones(length(position),1)*sub_id,selected_info.position,[1:length(position)]'];% sub_id, position, idx
        
        % find kurt > 5;
        kurt = selected_info.kurt(:,end-215:end);
        exclude = kurt>5;
        reserve_chan = sum(exclude,2)<100;% if over 100/216 trials kurtosis > 5,exclude this electrode
        [row, col] = find(exclude(reserve_chan,:)==1);
        data = data_selected_normalized(reserve_chan,:,:,end-215:end); 
        clear data_selected_normalized;
        
        % matrix 2 cell
        for chani =1:size(data,1)
            for triali =1:216
                data_cell{chani,triali} = squeeze(data(chani,:,:,triali));
            end
        end
        
        % exclude kurt>5's trials
        for i=1:length(row)
            data_cell{row(i), col(i)}=[];
        end
        
        % delet trial: sub_id =10, trial_id = 108+36
        if sub_id == 10
            data_cell{7, 108}=[];
        end
        
        % merge data
        seq_bd = [0:2,6:8]*18;
        seq_non_bd = [3:5,9:11]*18;
        for seqi=1:18
            for chani =1:size(data,1)
                data_bd{chani,seqi} =  mean(cell2matrix(data_cell(chani,seq_bd+seqi)),3);
                data_non_bd{chani,seqi}  =  mean(cell2matrix(data_cell(chani,seq_non_bd+seqi)),3);
            end
        end
        
        kurt_group=[kurt_group;kurt(reserve_chan,:)];
        info_group=[info_group;info(reserve_chan,:)];
        data_bd_group = [data_bd_group;data_bd];
        data_non_bd_group = [data_non_bd_group;data_non_bd];
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end
wavelet_channel.info = info_group;
wavelet_channel.kurt = kurt_group;
wavelet_channel.data_bd = data_bd_group;
wavelet_channel.data_non_bd = data_non_bd_group;

save(fullfile(save_dir,[brain_region,'_wavelet_channel.mat']),'wavelet_channel','-v7.3')
% wavelet group each subject
load(fullfile(read_dir,subject,[brain_region,'_wavelet_channel.mat']),'wavelet_group')
wavelet_subject = [];
sub_ids = unique(cell2mat(wavelet_channel.info(:,1)));
for i = 1:length(sub_ids)
    sub_id = sub_ids(i);
    idx = find(cell2mat(wavelet_channel.info(:,1))==sub_id);
    for triali =1:18
        wavelet_subject.data_bd{sub_id,triali} = mean(cell2matrix(wavelet_channel.data_bd(idx,triali)),3);
        wavelet_subject.data_non_bd{sub_id,triali} = mean(cell2matrix(wavelet_channel.data_non_bd(idx,triali)),3);
    end
end
wavelet_subject.info = wavelet_channel.info;
wavelet_subject.subjects = sub_ids;

save(fullfile(save_dir,[brain_region,'_wavelet_subject.mat']),'wavelet_subject','-v7.3')

%% Method 2, seeg data
label_table = readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/contacts.csv');
read_dir = '/bigvault/Projects/seeg_pointing/results/sequence_memory/';
brain_region= 'Hippocampus';
data_type = 'wavelet';
data_all = [];
info_group = struct('label_prob',[],'position',[]);

% extract seeg data
for sub_id=1:27
    subject = ['subject',num2str(sub_id)];
    try
        wavelet_dir = fullfile(read_dir, subject, 'wavelet');
        trial_select = 1: length(dir(wavelet_dir))-2;
        % read wavelet for each subject, Specify trials
        [data_selected, data_fixation, selected_info, positions] = get_seeg_in_brain_region(subject, brain_region, data_type, read_dir, label_table,trial_select);
        save(fullfile(read_dir,subject,[brain_region,'_wavelet.mat']),data_selected,'-v7.3')
        save(fullfile(read_dir,subject,[brain_region,'_fixation.mat']),data_fixation,'-v7.3')
        
        data_all{sub_id} = mean(data_selected,4);
        info_group.label_prob = vertcat(info_group.label_prob, selected_info);
        info_group.position{sub_id} = positions;
        info_group.selected_num{sub_id} = sum(positions);
        disp(subject)
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end

save_dir = read_dir;
save(fullfile(save_dir,[brain_region,'_',data_type,'.mat']),'data_all', '-v7.3')
save(fullfile(save_dir,[brain_region,'_',data_type,'_info.mat']),'info_group')

%% merge data 
sub_ids = [1,2,3,4,7,8,9,10,12,20,21,25];
data_epoch = single_brain_epoch(sub_ids);
save(['/bigvault/Projects/seeg_pointing/results/memory_group/hipp_epoch_2048'],'data_epoch', '-v7.3');

sub_ids = [15,17,18,19];
data_epoch = single_brain_epoch(sub_ids);
save(['/bigvault/Projects/seeg_pointing/results/memory_group/hipp_epoch_512'],'data_epoch', '-v7.3');

% down sample
for triali=1:216
    data_epoch.trial{1, triali}=downsample(data_epoch.trial{1, triali}',4)';
end

% merge data
% data_epoch 512, data_epoch1 20498
for triali=1:216
    data_epoch.trial{1, triali}=[data_epoch1.trial{1, triali};data_epoch.trial{1, triali}];
end
data_epoch.info = [data_epoch1.info;data_epoch.info];
data_epoch.label = [data_epoch1.label; data_epoch.label];
data_epoch.label_old = [data_epoch1.label_old; data_epoch.label_old];
data_epoch.position = [data_epoch1.position; data_epoch.position];
chan_num = size(data_epoch.label,1);
kurt =[];
for i=1:size(data_epoch.trial,2)
    data_t= data_epoch.trial{1,i};
    for pi =1:chan_num 
    kurt(pi,i) = kurtosis(data_t(pi,:));
    end
end
kurt5 = zeros(chan_num, 216);
for i=1:chan_num 
    idx = find(kurt(i,:)>5);
    kurt5(i,1:length(idx)) = idx;
end
data_epoch.kurt=kurt;
data_epoch.kurt5=kurt5;

% no epilespy
idx = find(data_epoch.info.epilepsy==0);
for triali=1:216
    data_epoch.trial{1, triali}=data_epoch.trial{1, triali}(idx,:);
end
data_epoch.info = data_epoch.info(idx,:);
data_epoch.label = data_epoch.label(idx,:);
data_epoch.label_old = data_epoch.label_old(idx,:);
data_epoch.position = data_epoch.position(idx,:);
data_epoch.kurt=data_epoch.kurt(idx,:);
data_epoch.kurt5=data_epoch.kurt5(idx,:);
%%
time_sw = 3*512+1:10.5*512; % original [-5.5,8], save [-2.5,5]
time_fixation = [450,550];
trial_num = length(data_epoch.trial);
srate = data_epoch.fsample;
mkdir([save_dir, 'wavelet'])
data_sw = [];
data_fixation = [];
subject = 'subject1_27';

for seti = 1:trial_num/18 % Reduce storage space
    waitbar(seti / (trial_num/18), h, sprintf('Wavelet trial: %d / %d', triali, trial_num/18)); % Update progress bar
    
    triali = (seti-1)*18+1:seti*18;
    % Wavelet analysis
    cfg = [];
    cfg.method = 'wavelet';
    cfg.pad = 'nextpow2';
    cfg.output = 'pow';
    cfg.channel = 'all';
    cfg.trials = triali;
    cfg.keeptrials = 'yes';
    cfg.width = 6;  %
    cfg.toi = 'all';
    cfg.foi = 1:120;  %
    data_wavelet = ft_freqanalysis(cfg, data_epoch);
    data_wavelet.powspctrm = data_wavelet.powspctrm(:,:,:,time_sw);
    save([save_dir, 'wavelet', '/', num2str(seti), '.mat'], 'data_wavelet', '-v7.3');
   
end
%% average bd and non boundary  -v1 Do not remove the trial
save_dir = '/bigvault/Projects/seeg_pointing/results/memory_group/'
powspctrm=zeros([18, 57, 120, 3840]);% 18, 57, 120, 3840
data_fixation = [];
srate =512;
time_sw = 3*512+1:10.5*512; % original [-5.5,8], save [-2.5,5]
fixation_idx = 4.5*srate+1:5.5*srate;% [450,550];, original [-5.5,8], save [-1,0]
for seti = [4:6,10:12]
    load([save_dir, 'wavelet', '/', num2str(seti), '.mat'], 'data_wavelet')
    powspctrm = powspctrm + data_wavelet.powspctrm(:,:,:,time_sw);
    disp(seti)
    data_fixation_temp = squeeze(mean(data_wavelet.powspctrm(:,:,:,fixation_idx),4));
    data_fixation = [data_fixation;data_fixation_temp];% channnel*frex*trails
end
powspctrm = powspctrm/6;
wavelet = [];
wavelet =  data_epoch;
wavelet = rmfield(wavelet, 'trial');
wavelet.data_fixation =  data_fixation;
wavelet.powspctrm =  powspctrm;% pici*chan*fre*time
wavelet.set = [4:6,10:12];


% data normalize
data_selected_normalized = [];
data_fixation_mean = squeeze(mean(data_fixation,1));
for chani =1:size(data_fixation_mean,1)
    for freqi =1:size(data_fixation_mean,2)
        data_selected_normalized(:,chani,freqi,:) = (powspctrm(:,chani,freqi,:)-data_fixation_mean(chani,freqi))/data_fixation_mean(chani,freqi);
    end
end

wavelet.powspctrm =  data_selected_normalized;



