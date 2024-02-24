% Modal
modal_result=[];
params.wavefreqs=1:120;
k=1;
varNames = {'sub_id', 'srate', 'channel', 'trial', 'bands_start', 'bands_end', 'frequency_sliding', 'bandpow', 'bandphases' };
varTypes = {'double', 'double', 'double', 'double', 'double', 'double', 'cell', 'cell', 'cell'};
modal_result = table('Size', [0, numel(varNames)], 'VariableNames', varNames, 'VariableTypes', varTypes);
subs = unique(hipp_info(:,1));
%
for subi = 1:length(subs)
    sub_id = subs(subi);
    disp(subject)
    subject = ['subject',num2str(sub_id)];
    load(['/bigvault/Projects/seeg_pointing/results/sequence_memory/',subject,'/',[subject,'_epoch.mat']])
    params.srate=data_epoch.fsample;
    chans = hipp_info(hipp_info(:,1)==sub_id,2);
    pre_trial_num = length(find(data_epoch.trialinfo(:,2)==0));%
    if length(find(data_epoch.trialinfo(:,2)~=0))~=216
        error(['somethion wrong in ',subject,', please check'])
    end
    for chani = 1:length(chans)
        chan_idx = chans(chani);
        disp([subject,' channel: ',num2str(chan_idx)])
        for triali = 1:216
            trial_idx = pre_trial_num + triali;
            signal = data_epoch.trial{1,trial_idx}(chan_idx,:);
            [frequency_sliding,bands,bandpow,bandphases] = MODAL(signal,params);
            for bandi =1:size(bands,1)
                modal_result(k,:) = {sub_id, params.srate, chan_idx, triali, bands(bandi,1), bands(bandi,2),{frequency_sliding(bandi,:)}, {bandpow(bandi,:)},{bandphases(bandi,:)}};
                k=k+1;
            end
        end
    end
end
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




