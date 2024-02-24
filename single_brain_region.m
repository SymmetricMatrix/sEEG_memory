% This code mainly about extract wavelet data in single brain:
% 1. extract each subject's raw seeg data 
% 2. downsample (sample rate is not consistent, 2048->512)
% 3. caculate wavelet
% 4. exclude epilespy trials
% 5.channel level to subject level
%
%  the criteria of contact belongs to a brain region
clc
clear
%% parameter setting
label_table = readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/contacts.csv');
brain_region= 'Hippocampus';
channels_selected = table2cell(label_table(contains(label_table.AAL3, brain_region) , {'sub_id'}));
tabulate(cell2mat(channels_selected))
read_dir = '/bigvault/Projects/seeg_pointing/results/sequence_memory/';
save_dir='/bigvault/Projects/seeg_pointing/results/memory_group/';


data_type = 'wavelet';
data_all = [];
info_group = struct('label_prob',[],'position',[]);

%% 0. show contacts 
contacts = readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/contacts.csv');
idx = (contains(contacts.HCPex,'Hippocampus') &(contacts.HCPex_MNI_linear__prob> 0.25));
idx = idx & (contacts.lab_inside == 1);
sub_contacts = contacts(idx,{'sub_id','lab_bs','AAL3','AAL3_prob','HCPex','HCPex_MNI_linear__prob'});

%% 1. extract seeg data
sub_ids = [1,2,3,4,7,8,9,10,12,20,21,25];
data_epoch = single_brain_epoch(sub_ids);
save(['/bigvault/Projects/seeg_pointing/results/memory_group/hipp_epoch_2048'],'data_epoch', '-v7.3');

sub_ids = [15,17,18,19];
data_epoch = single_brain_epoch(sub_ids);
save(['/bigvault/Projects/seeg_pointing/results/memory_group/hipp_epoch_512'],'data_epoch', '-v7.3');

%% 2. down sample
for triali=1:216
    data_epoch.trial{1, triali}=downsample(data_epoch.trial{1, triali}',4)';
end

% merge data, data_epoch 512, data_epoch1 20498
for triali=1:216
    data_epoch.trial{1, triali}=[data_epoch1.trial{1, triali};data_epoch.trial{1, triali}];
end
data_epoch.info = [data_epoch1.info;data_epoch.info];
data_epoch.label = [data_epoch1.label; data_epoch.label];
data_epoch.label_old = [data_epoch1.label_old; data_epoch.label_old];
data_epoch.position = [data_epoch1.position; data_epoch.position];
chan_num = size(data_epoch.label,1);

% caculate kurtosis
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

% exclude epilepsy channel
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
%% 3. wavelet
% parameter setting
time_sw = 3*512+1:10.5*512; % original [-5.5,8], save [-2.5,5]
time_fixation = [450,550];
trial_num = length(data_epoch.trial);
srate = data_epoch.fsample;
mkdir([save_dir, 'wavelet'])
data_sw = [];
data_fixation = [];
subject = 'subject1_27';

% wavelet for each set(18 pics)
for seti = 1:trial_num/18 % Reduce storage space
    waitbar(seti / (trial_num/18), h, sprintf('Wavelet trial: %d / %d', triali, trial_num/18)); % Update progress bar
    trials = (seti-1)*18+1:seti*18;
    % Wavelet analysis
    cfg = [];
    cfg.method = 'wavelet';
    cfg.pad = 'nextpow2';
    cfg.output = 'pow';
    cfg.channel = 'all';
    cfg.trials = trials;
    cfg.keeptrials = 'yes';
    cfg.width = 6;  %
    cfg.toi = 'all';
    cfg.foi = 1:120;  %
    data_wavelet = ft_freqanalysis(cfg, data_epoch);
    data_wavelet.powspctrm = data_wavelet.powspctrm(:,:,:,time_sw);
    save([save_dir, 'wavelet', '/', num2str(seti), '.mat'], 'data_wavelet', '-v7.3');
end
%% 4. exclude epilespy trials
% parameter setting
save_dir = '/bigvault/Projects/seeg_pointing/results/memory_group/'

powspctrm=[];
data_fixation = [];
powspctrm_sum = [];
srate =512;
time_sw = 3*srate+1:10.5*srate; % original [-5.5,8], save [-2.5,5]
fixation_idx = 1.5*srate+1:2.5*srate;% [450,550];, original [-5.5,8], save [-1,0]
k=1;
% exclude epilepsy trails (set nan)
load('/bigvault/Projects/seeg_pointing/results/memory_group/hipp_kurt.mat','kurt')
for seti = [4:6,10:12]
    trails = (seti-1)*18+1:seti*18;
    kurt5=[];
    disp(seti)
    load([save_dir, 'wavelet', '/', num2str(seti), '.mat'], 'data_wavelet')
    powspctrm_temp = data_wavelet.powspctrm(:,:,:,time_sw);
    kurt_temp = kurt(:,trails)';
    [kurt5(:,1),kurt5(:,2)] = ind2sub([size(kurt_temp)],find(kurt_temp>5));
    for i=1:size(kurt5,1)
        powspctrm_temp(kurt5(i,1),kurt5(i,2),:,:)=nan;
    end
    powspctrm(:,:,:,:,k) = powspctrm_temp;
    
    % save after 3 sets
    if k==3
        powspctrm_sum(:,:,:,:,floor(seti/7)+1) = squeeze(mean(powspctrm,5,'omitnan'));
        powspctrm=[];
        k=0;
    end
    
    % caculate fixation mean(Subject, channel, frequency specific)
%     data_fixation_temp = squeeze(mean(powspctrm_temp(:,:,:,fixation_idx),4,'omitnan'));
%     data_fixation = [data_fixation;data_fixation_temp];% channnel*frex*trails
    k=k+1;
end
load('/bigvault/Projects/seeg_pointing/results/memory_group/fixation.mat')
data_fixation_mean = squeeze(mean(data_fixation, 1,'omitnan')); 
%
powspctrm_sum = mean(powspctrm_sum,5,'omitnan');
% normalize, percentage change (vaule-mean)/mean
data_selected_normalized = [];
for chani =1:size(data_fixation_mean,1)
    for freqi =1:size(data_fixation_mean,2)
        data_selected_normalized(:,chani,freqi,:) = (powspctrm_sum(:,chani,freqi,:)-data_fixation_mean(chani,freqi))/data_fixation_mean(chani,freqi);
    end
end
save('/bigvault/Projects/seeg_pointing/results/memory_group/wavelet/wavelet_non_bd.mat','data_selected_normalized','-v7.3')
%%
% average bd and non boundary  -v1 Do not remove the trial
for seti = [4:6,10:12]
    load([save_dir, 'wavelet', '/', num2str(seti), '.mat'], 'data_wavelet')
    powspctrm = powspctrm + data_wavelet.powspctrm(:,:,:,time_sw);
    disp(seti)
    trials = (seti-1)*18+1:seti*18;
    kurt5 = data_epoch.kurt5(:,trials);
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

wavelet.powspctrm =  data_selected_normalized;
%
data_bd_theta = data_bd(:,:,1:30,2.5*512+1:7.5*512);
data_non_bd_theta = data_non_bd(:,:,1:30,2.5*512+1:7.5*512);
data_p = zeros(size(data_bd_theta,[1,3,4]));
data_t = zeros(size(data_bd_theta,[1,3,4]));
for i=1:size(data_bd_theta,1)
    for j=1:size(data_bd_theta,3)
        for k=1:size(data_bd_theta,4)
            [~,data_p(i,j,k),~,stats]=ttest(squeeze(data_bd_theta(i,:,j,k)),squeeze(data_non_bd_theta(i,:,j,k)));
            data_t(i,j,k) = stats.tstat;
        end
    end
end
figure;plt_wavelet_pic18(data_t.*(data_p<0.05))

% check boundary position
data_bd_theta = squeeze(mean(data_bd([7,13],:,1:30,:),1));
data_non_bd_theta = squeeze(mean(data_non_bd([7,13],:,1:30,:),1));
data_p = zeros(size(data_bd_theta,[2,3]));
data_t = zeros(size(data_bd_theta,[2,3]));
for i=1:size(data_bd_theta,2)
    for j=1:size(data_bd_theta,3)
            [~,data_p(i,j),~,stats]=ttest(squeeze(data_bd_theta(:,i,j)),squeeze(data_non_bd_theta(:,i,j)));
            data_t(i,j) = stats.tstat;
        
    end
end
figure;plt_imagesc(data_t.*(data_p<0.05),'wavelet_s')
%% 5.channel level to subject level, pic*subject*freq*time
data_bd = load_mat('/bigvault/Projects/seeg_pointing/results/memory_group/wavelet/wavele_bd.mat');
data_non_bd = load_mat('/bigvault/Projects/seeg_pointing/results/memory_group/wavelet/wavele_non_bd.mat');
info = data_epoch.info;
sub_ids = unique(info.sub_id);
wavelet.bd = [];
wavelet.non_bd = [];
for i = 1:length(sub_ids)
    sub_id = sub_ids(i);
    wavelet.bd(:,i,:,:) = squeeze(mean(data_bd(:,find(info.sub_id==sub_id),:,:),2));
    wavelet.non_bd(:,i,:,:) = squeeze(mean(data_non_bd(:,find(info.sub_id==sub_id),:,:),2));
end
wavelet.subject = sub_ids;
save('/bigvault/Projects/seeg_pointing/results/memory_group/wavelet/wavelet_subject.mat','wavelet','-v7.3')


% check boundary position
data_bd_theta = squeeze(mean(wavelet.bd(:,:,1:30,:),1));
data_non_bd_theta = squeeze(mean(wavelet.non_bd(:,:,1:30,:),1));
data_p = zeros(size(data_bd_theta,[2,3]));
data_t = zeros(size(data_bd_theta,[2,3]));
for i=1:size(data_bd_theta,2)
    for j=1:size(data_bd_theta,3)
            [~,data_p(i,j),~,stats]=ttest(squeeze(data_bd_theta(:,i,j)),squeeze(data_non_bd_theta(:,i,j)));
            data_t(i,j) = stats.tstat;
        
    end
end
figure;plt_imagesc(data_t.*(data_p<0.05),'wavelet_s')

data_bd_theta = wavelet.bd(:,:,1:30,:);
data_non_bd_theta = wavelet.non_bd(:,:,1:30,:);


%% save data without exclude epilepsy
% parameter setting
save_dir = '/bigvault/Projects/seeg_pointing/results/memory_group/'

powspctrm=[];
data_fixation = [];
powspctrm_sum = [];
srate =512;
time_sw = 3*srate+1:10.5*srate; % original [-5.5,8], save [-2.5,5]
fixation_idx = 1.5*srate+1:2.5*srate;% [450,550];, original [-5.5,8], save [-1,0]
k=1;
% exclude epilepsy trails (set nan)
for seti = [1:3,7:9]
    trails = (seti-1)*18+1:seti*18;
    disp(seti)
    load([save_dir, 'wavelet', '/', num2str(seti), '.mat'], 'data_wavelet')
    powspctrm_temp = data_wavelet.powspctrm(:,:,:,time_sw);
    powspctrm(:,:,:,:,k) = powspctrm_temp;
    clear data_wavelet;
    clear powspctrm_temp;
    
    % save after 3 sets
    if k==3
        powspctrm_sum(:,:,:,:,floor(seti/7)+1) = squeeze(mean(powspctrm,5,'omitnan'));
        powspctrm=[];
        k=0;
    end
    k=k+1;
end
powspctrm1 = squeeze(mean(powspctrm_sum,5,'omitnan'));
%
powspctrm=[];
data_fixation = [];
powspctrm_sum = [];
k=1;
for seti = [4:6,10:12]
    trails = (seti-1)*18+1:seti*18;
    disp(seti)
    load([save_dir, 'wavelet', '/', num2str(seti), '.mat'], 'data_wavelet')
    powspctrm_temp = data_wavelet.powspctrm(:,:,:,time_sw);
    powspctrm(:,:,:,:,k) = powspctrm_temp;
    clear data_wavelet;
    clear powspctrm_temp;
    
    % save after 3 sets
    if k==3
        powspctrm_sum(:,:,:,:,floor(seti/7)+1) = squeeze(mean(powspctrm,5,'omitnan'));
        powspctrm=[];
        k=0;
    end
    k=k+1;
end
powspctrm2 = squeeze(mean(powspctrm_sum,5,'omitnan'));

fixation(:,:,1) = mean(powspctrm1(:,:,:,fixation_idx),[1,4]);
fixation(:,:,2) = mean(powspctrm2(:,:,:,fixation_idx),[1,4]);
data_fixation_mean = mean(fixation,3);

% normalize, percentage change (vaule-mean)/mean
data_normalized_bd = [];
data_normalized_non_bd =[];
for chani =1:size(data_fixation_mean,1)
    for freqi =1:size(data_fixation_mean,2)
        data_normalized_bd(:,chani,freqi,:) = (powspctrm1(:,chani,freqi,:)-data_fixation_mean(chani,freqi))/data_fixation_mean(chani,freqi);
        data_normalized_non_bd(:,chani,freqi,:) = (powspctrm2(:,chani,freqi,:)-data_fixation_mean(chani,freqi))/data_fixation_mean(chani,freqi);
    end
end

wavelet.bd=data_normalized_bd;
wavelet.non_bd=data_normalized_non_bd;
save('/bigvault/Projects/seeg_pointing/results/memory_group/wavelet/wavelet_raw.mat','wavelet','-v7.3')
%% plot figure to manual exclude epilepsy
channel_id = [10,11,34,38,42,46,47,52,53,54];
srate=512;
time_sw = 3*srate+1:10.5*srate;
for seti = 1:12
    disp(seti)
    load([save_dir, 'wavelet', '/', num2str(seti), '.mat'], 'data_wavelet')
    powspctrm_sum = data_wavelet.powspctrm;
    for i = 1:length(channel_id)
        chani = channel_id(i);
        data_selected_normalized = [];
            for freqi =1:size(data_fixation_mean,2)
                data_selected_normalized(:,freqi,:) = squeeze((powspctrm_sum(:,chani,freqi,time_sw)-data_fixation_mean(chani,freqi))/data_fixation_mean(chani,freqi));
            end
        figure
        data = squeeze(data_selected_normalized);
        plt_wavelet_pic18(data)
        sgtitle(['set:',num2str(seti),'  channel:',num2str(chani)])
    end
end
%% save data with manual exclude epilepsy
T = readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/SEEG.xlsx', 'Sheet', 'epilepsy', 'ReadVariableNames', true,'VariableNamingRule','preserve');
T = T(1:216,:);
chan_ids = T.Properties.VariableNames(3:end);

powspctrm=[];
data_fixation = [];
powspctrm_sum = [];
srate =512;
time_sw = 3*srate+1:10.5*srate; % original [-5.5,8], save [-2.5,5]
fixation_idx = 1.5*srate+1:2.5*srate;% [450,550];, original [-5.5,8], save [-1,0]
k=1;
load('/bigvault/Projects/seeg_pointing/results/memory_group/hipp_kurt.mat','kurt')
for seti = [1:3,7:9]
    trails = (seti-1)*18+1:seti*18;
    kurt5=[];
    disp(seti)
    load([save_dir, 'wavelet', '/', num2str(seti), '.mat'], 'data_wavelet')
    powspctrm_temp = data_wavelet.powspctrm(:,:,:,time_sw);
    kurt_temp = kurt(:,trails)';
    [kurt5(:,1),kurt5(:,2)] = ind2sub([size(kurt_temp)],find(kurt_temp>5));
    % exclude kurtosis>5
    for i=1:size(kurt5,1)
        powspctrm_temp(kurt5(i,1),kurt5(i,2),:,:)=nan;
    end
    
    % exclude manual select
%     for i=1:length(chan_ids)
%         chan_id  = chan_ids{i} % str
%         ids = table2array(T(table2array(T(:,chan_id)) == 1,'trial'));
%         trial_ids = ids(ismember(ids,trails))-(seti-1)*18;
%         for j=1:length(trial_ids)
%             trial_id = trial_ids(j)
%             powspctrm_temp(trial_id,str2num(chan_id),:,:)=nan;
%         end
%     end
    
    powspctrm(:,:,:,:,k) = powspctrm_temp;
    % save after 3 sets
    if k==3
        powspctrm_sum(:,:,:,:,floor(seti/7)+1) = squeeze(mean(powspctrm,5,'omitnan'));
        powspctrm=[];
        k=0;
    end
    
    % caculate fixation mean(Subject, channel, frequency specific)
%     data_fixation_temp = squeeze(mean(powspctrm_temp(:,:,:,fixation_idx),4,'omitnan'));
%     data_fixation = [data_fixation;data_fixation_temp];% channnel*frex*trails
    k=k+1;
end
powspctrm1 = squeeze(mean(powspctrm_sum,5,'omitnan'));
save('/bigvault/Projects/seeg_pointing/results/memory_group/wavelet/wavelet_kurt_1.mat','powspctrm1','-v7.3')


% save data with manual exclude epilepsy
T = readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/SEEG.xlsx', 'Sheet', 'epilepsy', 'ReadVariableNames', true,'VariableNamingRule','preserve');
T = T(1:216,:);
chan_ids = T.Properties.VariableNames(3:end);

powspctrm=[];
data_fixation = [];
powspctrm_sum = [];
srate =512;
time_sw = 3*srate+1:10.5*srate; % original [-5.5,8], save [-2.5,5]
fixation_idx = 1.5*srate+1:2.5*srate;% [450,550];, original [-5.5,8], save [-1,0]
k=1;
load('/bigvault/Projects/seeg_pointing/results/memory_group/hipp_kurt.mat','kurt')
for seti = [4:6,10:12]
    trails = (seti-1)*18+1:seti*18;
    kurt5=[];
    disp(seti)
    load([save_dir, 'wavelet', '/', num2str(seti), '.mat'], 'data_wavelet')
    powspctrm_temp = data_wavelet.powspctrm(:,:,:,time_sw);
    kurt_temp = kurt(:,trails)';
    [kurt5(:,1),kurt5(:,2)] = ind2sub([size(kurt_temp)],find(kurt_temp>5));
    % exclude kurtosis>5
    for i=1:size(kurt5,1)
        powspctrm_temp(kurt5(i,1),kurt5(i,2),:,:)=nan;
    end
    
    % exclude manual select
%     for i=1:length(chan_ids)
%         chan_id  = chan_ids{i} % str
%         ids = table2array(T(table2array(T(:,chan_id)) == 1,'trial'));
%         trial_ids = ids(ismember(ids,trails))-(seti-1)*18;
%         for j=1:length(trial_ids)
%             trial_id = trial_ids(j)
%             powspctrm_temp(trial_id,str2num(chan_id),:,:)=nan;
%         end
%     end
    
    powspctrm(:,:,:,:,k) = powspctrm_temp;
    % save after 3 sets
    if k==3
        powspctrm_sum(:,:,:,:,floor(seti/7)+1) = squeeze(mean(powspctrm,5,'omitnan'));
        powspctrm=[];
        k=0;
    end
    
    % caculate fixation mean(Subject, channel, frequency specific)
%     data_fixation_temp = squeeze(mean(powspctrm_temp(:,:,:,fixation_idx),4,'omitnan'));
%     data_fixation = [data_fixation;data_fixation_temp];% channnel*frex*trails
    k=k+1;
end
powspctrm2 = squeeze(mean(powspctrm_sum,5,'omitnan'));
save('/bigvault/Projects/seeg_pointing/results/memory_group/wavelet/wavelet_kurt_2.mat','powspctrm2','-v7.3')

fixation(:,:,1) = mean(powspctrm1(:,:,:,fixation_idx),[1,4]);
fixation(:,:,2) = mean(powspctrm2(:,:,:,fixation_idx),[1,4]);
data_fixation_mean = mean(fixation,3);

% normalize, percentage change (vaule-mean)/mean
data_normalized_bd = [];
data_normalized_non_bd =[];
for chani =1:size(data_fixation_mean,1)
    for freqi =1:size(data_fixation_mean,2)
        data_normalized_bd(:,chani,freqi,:) = (powspctrm1(:,chani,freqi,:)-data_fixation_mean(chani,freqi))/data_fixation_mean(chani,freqi);
        data_normalized_non_bd(:,chani,freqi,:) = (powspctrm2(:,chani,freqi,:)-data_fixation_mean(chani,freqi))/data_fixation_mean(chani,freqi);
    end
end
wavelet_manual.bd=data_normalized_bd;
wavelet_manual.non_bd=data_normalized_non_bd;
%save('/bigvault/Projects/seeg_pointing/results/memory_group/wavelet/wavelet_manual.mat','wavelet_manual','-v7.3')
save('/bigvault/Projects/seeg_pointing/results/memory_group/wavelet/wavelet_kurt.mat','wavelet','-v7.3')

%% epoch with manual exclude
T = readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/SEEG.xlsx', 'Sheet', 'epilepsy', 'ReadVariableNames', true,'VariableNamingRule','preserve');
T = T(1:216,:);
chan_ids = T.Properties.VariableNames(3:end);

% exclude manual select
for i=1:length(chan_ids)
    chan_id  = chan_ids{i} % str
    ids = table2array(T(table2array(T(:,chan_id)) == 1,'trial'));
    for j=1:length(ids)
        trial_id = ids(j);
        freq.fourierspctrm(trial_id,str2num(chan_id),:,:)=nan;
    end
end

% delet channel 52,53
freq.fourierspctrm(:,[52,53],:,:)=nan;
