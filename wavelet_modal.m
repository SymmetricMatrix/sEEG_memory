% Modal
modal_result=[];
params.wavefreqs=1:30;
params.srate=512;
params.local_winsize_sec = 3;
k=1;
varNames = {'sub_id', 'srate', 'channel', 'trial', 'bands_start', 'bands_end', 'frequency_sliding', 'bandpow', 'bandphases' };
varTypes = {'double', 'double', 'double', 'double', 'double', 'double', 'cell', 'cell', 'cell'};
modal_result = table('Size', [0, numel(varNames)], 'VariableNames', varNames, 'VariableTypes', varTypes);


load('/bigvault/Projects/seeg_pointing/results/memory_group/hipp_epoch_no_epi.mat')
chan_num = size(data_epoch.trial{1, 1},1);
data_reserve = data_epoch.kurt<5;

% % save data with manual exclude epilepsy
% T = readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/SEEG.xlsx', 'Sheet', 'epilepsy', 'ReadVariableNames', true,'VariableNamingRule','preserve');
% T = T(1:216,:);
% chan_ids = T.Properties.VariableNames(3:end);
% for i=1:length(chan_ids)
%     chan_id  = chan_ids{i}; % str
%     ids = table2array(T(:,chan_id)) == 1;
%     temp = data_reserve(str2num(chan_id),:).*(~ids');
%     data_reserve(str2num(chan_id),:) = temp;
% end
% delete channel 52,53

for triali = 1:length(data_epoch.trial)
    for chani = 1:chan_num
        % check kurt and manual selection
        if data_reserve(chani,triali)==1
            signal = data_epoch.trial{1,triali}(chani,:);
            [frequency_sliding,bands,bandpow,bandphases] = MODAL(signal,params);
            for bandi =1:size(bands,1)
                modal_result(k,:) = {data_epoch.info.sub_id(chani), params.srate, chani, triali, bands(bandi,1), bands(bandi,2),{frequency_sliding(bandi,:)}, {bandpow(bandi,:)},{bandphases(bandi,:)}};
                k=k+1;
            end
        end
    end
end

%% visulization
index = [7,13,25,31,43,49];
bd_id = [index,index+18*6];
non_bd_id = [index+18*3,index+18*9];
% bd_id = [1:18*3,18*6+1:18*9];
% non_bd_id = [18*3+1:18*6,18*9+1:18*12];
time_idx = round(512*0+1:512*7.5);

% trials_num = size(unique(modal_temp(:, [1,3,4]), 'rows'),1);
% time
plot_type ='count';
figure
subplot(1,2,1)
modal_temp1 = modal_result(ismember(modal_result.trial,bd_id) & (~ismember(modal_result.channel,[52,53])) ,:);
plt_model(modal_temp1,time_idx,plot_type)
yline(0.4,'--')
yline(0.2,'--')
y_limit1 = ylim;
title('bd position')

subplot(1,2,2)
modal_temp2 = modal_result(ismember(modal_result.trial,non_bd_id) & (~ismember(modal_result.channel,[52,53])) ,:);
plt_model(modal_temp2,time_idx,plot_type)
yline(0.4,'--')
yline(0.2,'--')
ylim(y_limit1);
title('non bd position')
% sgtitle('peak detect counts in each frequency')
sgtitle('power mean in each frequency')
%% 18 pictures
index = [1,19,37]-1;
bd_id = [index,index+18*6];
non_bd_id = [index+18*3,index+18*9];
time_idx = round(512*2.5+1:512*5);

plot_type ='hist';
figure
for i=1:18
    subplot(3,6,i)
    modal_temp1 = modal_result(ismember(modal_result.trial,bd_id+i) & (~ismember(modal_result.channel,[52,53])),:);
    plt_model(modal_temp1,time_idx,plot_type,'r')
    yline(0.4,'--')
    yline(0.2,'--')
    if i==1
        y_limit1 = ylim;
    end
    hold on
    modal_temp2 = modal_result(ismember(modal_result.trial,non_bd_id+i) & (~ismember(modal_result.channel,[52,53])),:);
    plt_model(modal_temp2,time_idx,plot_type,'b')
    yline(0.4,'--')
    yline(0.2,'--')
    ylim(y_limit1);
    title(['pic ',num2str(i)])
end
sgtitle('manual data,time 2.5~5s')
%% LMM
chan_num = length(unique(modal_result.channel));
freq_num = 30;
trial_num = 216;
result = zeros(chan_num,trial_num,freq_num);
time_idx = round(512*5+1:512*7.5);
for chani=1:chan_num
    for triali= 1:216
        bands_all=[];
        modal_temp=modal_result((modal_result.trial==triali) & (modal_result.channel==chani) ,:);
        freq_temp = cell2matrix(modal_temp.frequency_sliding);
        if ~isempty(freq_temp)
            freq=[];
            freq_bands=[];
            if length(size(freq_temp))==3
                freq = squeeze(freq_temp);
            else
                freq = freq_temp';
            end
            freq(:,:) = freq_temp(1,:,:);
            freq = freq(time_idx,:);% signal* time
            freq_bands(:,1) = min(freq);
            freq_bands(:,2) = max(freq);
            freq_bands = round(freq_bands);
            for i=1:size(modal_temp,1)
                if ~any(isnan(freq_bands(i,:)))
                    bands_all = [bands_all,freq_bands(i,1):freq_bands(i,2)];
                end
            end
            result(chani,triali,bands_all)=1;
        end
    end
end


result18=zeros(chan_num,36,freq_num);
index = [1,19,37]-1;
bd_id = [index,index+18*6];
non_bd_id = [index+18*3,index+18*9];
for i=1:18
    result18(:,i,:)= mean(result(:,bd_id+i,:),2,'omitnan');
    result18(:,i+18,:)= mean(result(:,non_bd_id+i,:),2,'omitnan');
end

% subject
load('/bigvault/Projects/seeg_pointing/results/memory_group/hipp_epoch_no_epi.mat')
subject = data_epoch.info.sub_id;
subject_design = reshape(repmat(subject,[36,30]),[57,36,30]);

color = [ones(chan_num,18),ones(chan_num,18)*2];
color_design = repmat(color,[1,1,30]);

position = ones(chan_num,1)*[1:18,1:18];
position_design = repmat(position,[1,1,30]);

freq=zeros(1,1,30);
freq(1,1,:) =1:30;
freq_design = repmat(freq,[chan_num,36,1]);

design=[];
design(:,:,:,1) = result18;
design(:,:,:,2) = subject_design;
design(:,:,:,3) = position_design;
design(:,:,:,4) = color_design;
design(:,:,:,5) = freq_design;

design([52, 53], :, :, :) = [];
design = reshape(design,[],5);

tbl = table(design(:,1),design(:,2),design(:,3),design(:,4),design(:,5), 'VariableNames', {'detect', 'subject', 'position', 'color', 'freq'});
for freqi=2:9
    disp(freqi)
    lme = fitlme(tbl((tbl.freq==freqi) ,:),'detect~1+position+color+position*color+(1|subject)')
end
%%
% subject
subject = data_epoch.info.sub_id;
subject_design = reshape(repmat(subject,[36,2]),[57,36,2]);

color = [ones(chan_num,18),ones(chan_num,18)*2];
color_design = repmat(color,[1,1,2]);

position = ones(chan_num,1)*[1:18,1:18];
position_design = repmat(position,[1,1,2]);

freq=[];
freq(1,1,:) =1:2;
freq_design = repmat(freq,[chan_num,36,1]);

design=[];
result18_temp(:,:,1)=mean(result18(:,:,[2:5]),3);
result18_temp(:,:,2)=mean(result18(:,:,[6:9]),3);
design(:,:,:,1) = result18_temp;
design(:,:,:,2) = subject_design;
design(:,:,:,3) = position_design;
design(:,:,:,4) = color_design;
design(:,:,:,5) = freq_design;

%design([52, 53], :, :, :) = [];
design = reshape(design,[],5);

tbl = table(design(:,1),design(:,2),design(:,3),design(:,4),design(:,5), 'VariableNames', {'detect', 'subject', 'position', 'color', 'freq'});
lme = fitlme(tbl((tbl.freq==1)& ismember(tbl.position,[7,13]) ,:),'detect~1+position+color+position*color+(1|subject)')
%% visulization
index = [7,13,25,31,43,49];
bd_id = [index,index+18*6];
non_bd_id = [index+18*3,index+18*9];
modal_temp = modal_result(ismember(modal_result.trial,non_bd_id),:);


% downsample
for i=1:size(modal_result,1)
    if modal_result.srate(i)==2048 & length(modal_result.frequency_sliding{i,1})==27649
        modal_result.frequency_sliding{i,1}=downsample(modal_result.frequency_sliding{i,1},4 );
        modal_result.bandpow{i,1}=downsample(modal_result.bandpow{i,1},4 );
        modal_result.bandphases{i,1}=downsample(modal_result.bandphases{i,1},4);
    end
    
end


% bands - edges of each detected band. Bands X 2 (lower,upper edge)
modal_temp = modal_result;
trials_num = size(unique(modal_temp(:, [1,3,4]), 'rows'),1);
bands_all=[];

for i=1:size(modal_temp,1)
    bands_all = [bands_all,modal_temp.bands_start(i):modal_temp.bands_end(i)];
end
figure
h = histogram(bands_all, 'BinEdges', [0:1:120]);
bin_values = h.Values;
normalized_values = bin_values / trials_num;
bar(h.BinEdges(1:end-1), normalized_values, 'histc');

figure
h = histogram(bands_all, 'Normalization', 'countdensity');
h.Values = h.Values /trials_num;
title('all')

modal_temp = modal_result(ismember(modal_result.trial,bd_id),:);
bands_all=[];
for i=1:size(modal_temp,1)
    bands_all = [bands_all,modal_temp.bands_start(i):modal_temp.bands_end(i)];
end
figure
histogram(bands_all, 'BinEdges', [0:5:120])%,'Normalization','probability')
title('boundary')

modal_temp = modal_result(ismember(modal_result.trial,non_bd_id),:);
bands_all=[];
for i=1:size(modal_temp,1)
    bands_all = [bands_all,modal_temp.bands_start(i):modal_temp.bands_end(i)];
end
figure
histogram(bands_all, 'BinEdges', [0:5:120])%,'Normalization','probability')
title('non boundary')

% time
% trial level frequency and time

% frequency sliding- instantaneous frequency of signal in each band.(Bands X samples)
fs = squeeze(cell2matrix(modal_result.frequency_sliding));
figure
imagesc(fs')
colorbar()
xticks(0:256:13.5*512);
xticklabels([-5.5*512:256:8*512]/512);
xlabel('Sequence pic /s')
% bandpow - average power of signal in each detected band. (Bands X samples)


% bandphase - instantaneous phase of signal in each detected band (Bands X samples)




