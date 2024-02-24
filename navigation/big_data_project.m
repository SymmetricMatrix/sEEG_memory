% The given code reads data from two csv files and multiple mat files, and
% stores the data in a cell array called data. The data is organized in rows,
% where each row corresponds to a specific trial, label, and subject.

home_dir='/bigvault/Projects/seeg_pointing/results/3dpointing/';
pointing=readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/pointing.csv');
contacts=readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/contacts.csv');

%%
tic
data = [];% data,sample_rate,error,decision_time
k = 1;
for sub_id =27:38
    subject = strcat('subject', num2str(sub_id));
    try
        % get srate and label labels
        data_pre_header = ft_read_header([home_dir,subject,'/',subject,'_pre.mat']);
        srate = data_pre_header.Fs;
        labels = data_pre_header.label;
        
        % get data
        load([home_dir,subject,'/',subject,'_epoch.mat'])
        [label_num,trials]=size(data_epoch);
        
        [trial_ids, label_ids] = meshgrid(1:trials, 1:label_num);
        
        for i = 1:numel(trial_ids)
            trial = trial_ids(i);
            label_id = label_ids(i);
            
            % get pointing time and pointing error
            pointing_time = table2array(pointing(pointing.sub_id==sub_id & pointing.trial==trial, {'pointing_time'}));
            pointing_error = table2array(pointing(pointing.sub_id==sub_id & pointing.trial==trial, {'error'}));
            
            % get label name and location of contacts
            sub_contacts = contacts(contacts.sub_id==sub_id &(contacts.AAL3_prob> 0.25)& (contacts.lab_inside == 1),:);
            label_name = labels{label_id};
            loc = strsplit(label_name, '-');
            loc1 = table2array(sub_contacts(strcmp(sub_contacts.lab_bs, loc{1}), {'AAL3'}));
            loc2 = table2array(sub_contacts(strcmp(sub_contacts.lab_bs, loc{2}), {'AAL3'}));
            seeg = data_epoch{label_id,trial};
            
            % store the extracted information in the data cell array
            if (~isempty(loc1)) && (~isempty(loc2)) && (~isempty(seeg))
                if srate == 2048
                    seeg =downsample(seeg,4);
                end
                kurt = kurtosis(seeg);
                if (~isempty(seeg)) && strcmp(loc1{1},loc2{1}) && (kurt<5)% exclude empty trials
                    data{k,1} = sub_id;
                    data{k,2} = srate;
                    data{k,3} = trial;
                    data{k,4} = label_id;
                    data{k,5} = label_name;
                    data{k,6} = loc1{1};
                    data{k,7} = table2array(sub_contacts(strcmp(sub_contacts.lab_bs, loc{1}), {'AAL3_prob'}));
                    data{k,8} = table2array(sub_contacts(strcmp(sub_contacts.lab_bs, loc{1}), {'MNI'}));
                    data{k,9} = loc2{1};
                    data{k,10} = table2array(sub_contacts(strcmp(sub_contacts.lab_bs, loc{2}), {'AAL3_prob'}));
                    data{k,11} = table2array(sub_contacts(strcmp(sub_contacts.lab_bs, loc{2}), {'MNI'}));
                    data{k,12} = pointing_time;
                    data{k,13} = pointing_error;
                    data{k,14} = table2array(contacts(contacts.sub_id==sub_id & strcmp(contacts.lab_bs, loc{1}), {'lab_excl_nav'}));
                    data{k,15} = table2array(contacts(contacts.sub_id==sub_id & strcmp(contacts.lab_bs, loc{2}), {'lab_excl_nav'}));
                    data{k,16} = kurt;
                    data{k,17} = seeg;
                    k=k+1;
                end
            end
        end
        
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end
toc


data = cell2table(data,'VariableNames', {'sub_id', 'srate','trial','label_idx','label','location1','loc1_prob','loc1_mni','location2','loc2_prob','loc2_mni','pointing_time', 'pointing_error','lab_excl_nav1','lab_excl_nav2','kurt','seeg'});
%%
save(['/bigvault/Projects/seeg_pointing/results/3dpointing/machine_learning/2024/data_512_2.mat'],'data','-v7.3' )

jsonStr = jsonencode(data);
fid = fopen(['/bigvault/Projects/seeg_pointing/results/3dpointing/machine_learning/2024/data_512_2.json'], 'w');
fprintf(fid, '%s', jsonStr);
fclose(fid);
%writetable(data(:,1:11),'/konglab/home/xicwan/big_data/data_start_info.csv')
%%
data2_info = data2(:,1:17);
data2_seeg = squeeze(cell2matrix(table2cell(data2(:,18))))';
save(['/bigvault/Projects/seeg_pointing/results/3dpointing/machine_learning/subject/data2.mat'],'data2_info')                                    
save(['/bigvault/Projects/seeg_pointing/results/3dpointing/machine_learning/subject/data2_seeg.mat'],'data2_seeg')

data4_info = data4(:,1:17);
data4_seeg = squeeze(cell2matrix(table2cell(data4(:,18))))';
save(['/bigvault/Projects/seeg_pointing/results/3dpointing/machine_learning/subject/data4.mat'],'data4_info')
save(['/bigvault/Projects/seeg_pointing/results/3dpointing/machine_learning/subject/data4_seeg.mat'],'data4_seeg')

data6_info = data6(:,1:17);
data6_seeg = squeeze(cell2matrix(table2cell(data6(:,18))))';
save(['/bigvault/Projects/seeg_pointing/results/3dpointing/machine_learning/subject/data6.mat'],'data6_info')
save(['/bigvault/Projects/seeg_pointing/results/3dpointing/machine_learning/subject/data6_seeg.mat'],'data6_seeg')

%%
% Filter data where location1 and location2 are equal
%data1 = data(strcmp(data.location1, data.location2), :);

location_name = 'Temporal_Mid L';
data_location = data1(strcmp(data1.location1, location_name), :);
kurs(data_location.seeg)
% downsample
for i = 1:size(data_location,1)
    if ~ismember(data_location.sub_id(i), [15,17,18,19])
        data_location.seeg{i} = downsample(data_location.seeg{i}, 4);
    end
end
loaction_name = strrep(location_name, ' ', '_');
writetable(data_locatin,['/bigvault/Projects/seeg_pointing/results/3dpointing/machine_learning/',location_name,'_512.csv']);
%save(['/bigvault/Projects/seeg_pointing/results/3dpointing/machine_learning/',location_name,'_512.mat'],'data_location','-v7.3')
%%
%writetable(ans, '/konglab/home/xicwan/big_data/data_start.json', 'FileType', 'json');

for i=1:5
    jsonStr = jsonencode(data(50001:end,:));
    fid = fopen(['/konglab/home/xicwan/big_data/data_start',num2str(i),'.json'], 'w');
    fprintf(fid, '%s', jsonStr);
    fclose(fid);
end
%% pre
data = data_location;
kur =[];
for i =1:size(data,1)
    kur(i) = kurtosis(data.seeg{i,1});
end
data_exclued = data(kur<5,:);
%data_same_region = data_exclued(strcmp(data_exclued.location1,data_exclued.location2), :);

%% run SPRiNT
trial_position = 'start';
load([trial_position,'_noepi_bipolar.mat'])
location_names = {'Fusiform L','Temporal_Inf L','Frontal_Inf_Orb_2 L','OFCpost L'}%'Temporal_Sup L','Hippocampus R','ParaHippocampal R','Hippocampus L','Frontal_Inf_Tri L'};
for i = 1:length(location_names)
    location_name = location_names{i};
    tic
    [s_512, s_2048] = calculate_sprint(data_same_region, location_name);
    toc
    s=[];
    s.s_512 = s_512;
    s.s_2048 = s_2048;
    save(['/bigvault/Projects/seeg_pointing/results/3dpointing/machine_learning/',trial_position,'_',strrep(location_name, ' ', '_'),'_SPRiNT.mat'],'s')
end
%%
trial_position = 'start';
location_names = {'Frontal_Inf_Tri L','Temporal_Mid L','Temporal_Sup L'};
location_name =  location_names{1}
load(['/bigvault/Projects/seeg_pointing/results/3dpointing/machine_learning/',trial_position,'_',strrep(location_name, ' ', '_'),'_SPRiNT.mat'])
s_512 = s.s_512;
s_2048 = s.s_2048 ;
figure
subplot(211)
plotSPRiNT(s_512, s_2048, location_name, 'pdf')
subplot(212)
plotSPRiNT(s_512, s_2048, location_name, 'hist')
sgtitle([trial_position,'_',strrep(location_name, ' ', '_'),': ',trial_position])