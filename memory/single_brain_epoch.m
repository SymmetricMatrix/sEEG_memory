function data_epoch1 = single_brain_epoch(sub_ids)
% extract hippocampus epoch data for each sub_ids in sequence_memory task
% Input: sub_ids, 1*N  matrix
% Output: data_epoch1

% find hippocampus region
contacts = readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/contacts.csv');
%idx = (contains(contacts.AAL3,'Hippocampus') & (contacts.AAL3_prob> 0.25)) | (contains(contacts.HCPex,'Hippocampus') &(contacts.HCPex_MNI_linear__prob> 0.25));
idx = (contains(contacts.HCPex,'Hippocampus') &(contacts.HCPex_MNI_linear__prob> 0.25));
idx = idx & (contacts.lab_inside == 1);
sub_contacts=contacts(idx,{'sub_id','lab_bs','AAL3','AAL3_prob','HCPex','HCPex_MNI_linear__prob'});

position =[];
data=cell(1,216);
label =[];
info =[];

% merge data from each sub_ids
for i = 1:length(sub_ids)
    sub_id = sub_ids(i);
    subject = ['subject',num2str(sub_id)];
    disp(subject)
    load(fullfile('/bigvault/Projects/seeg_pointing/results/sequence_memory/',subject,[subject,'_epoch.mat']),'data_epoch')
    load(fullfile('/bigvault/Projects/seeg_pointing/results/sequence_memory/',subject,[subject,'_channel.mat']),'channel')
    if sub_id ==1
        data_epoch.trial =  data_epoch.trial(1,1:end-18);
    elseif sub_id == 4
        data_epoch.trial =  data_epoch.trial(1,[19:180,199:252]);
    end
    
    % channel
    temp = sub_contacts(sub_contacts.sub_id==sub_id,:);
    label_region = check_two_ele(channel, temp.lab_bs); % Get the label region using the check_two_ele function
    positions = ismember(channel, label_region);
    chan_num = sum(positions);
    
    for i=1:216
        data_t= data_epoch.trial{1,end-(216-i)}(positions,:);
        data{1,i}=[data{1,i};data_t];
    end
    label = [label;data_epoch.label(positions,:)];
    position = [position;sub_id*ones(chan_num,1),find(positions~=0)];
    load(fullfile('/bigvault/Projects/seeg_pointing/results/sequence_memory/',subject,[subject,'_channel_summary.mat']),'channel')
    info = [info;channel(positions,:)];
end

% save data into data_epoch1
data_epoch1.trial = data;
data_epoch1.fsample = data_epoch.fsample ;
data_epoch1.label_old = label;
data_epoch1.label=strcat(label,'_', num2str(position(:,1)));
data_epoch1.position = position;
data_epoch1.time = data_epoch.time(1,1:216);
col_names = {'sub_id'; 'chan_id'; 'label'; 'label1';'MNI1'; 'AAL3_1';'AAl3_prob_1';'HCPex_1';'HCPex_prob_1';'label2';'MNI2'; 'AAL3_2';'AAl3_prob_2';'HCPex_2';'HCPex_prob_2';'epilepsy'};
data_epoch1.info = cell2table([num2cell(position),info,num2cell(zeros(size(info,1),1))], 'VariableNames', col_names);

% caculate kurtosis
chan_num = size(label,1);
kurt =[];
for i=1:size(data_epoch1.trial,2)
    data_t= data_epoch1.trial{1,i};
    for pi =1:chan_num 
    kurt(pi,i) = kurtosis(data_t(pi,:));
    end
end
kurt5 = zeros(chan_num, 216);
for i=1:chan_num 
    idx = find(kurt(i,:)>5);
    kurt5(i,1:length(idx)) = idx;
end
data_epoch1.kurt=kurt;
data_epoch1.kurt5=kurt5;

% select deleted channel
freq = sum(kurt5~=0,2);
data_epoch1.info{find(freq>50),end}=1;


end