clc
clear

%% select specific brain region
label_table=readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/contacts.csv');
read_dir = '/bigvault/Projects/seeg_pointing/results/object_recognition/';
brain_region='Hippocampus ';
data_all=[];
info_all =[];
for sub_id=1:17
    subject = ['subject',num2str(sub_id)];
    try
    load([read_dir,subject,'/',subject,'_epoch.mat']);
    
    [data_selected, info_selected] = get_seeg_in_brain_region(data_epoch, sub_id, label_table, brain_region);
    data_all{sub_id}=data_selected;
    info_all=vertcat(info_all, info_selected);
    
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end

%% To rule out possible epileptic discharges
kurtosis(data)

%% event boundary infulence
% 1. wavelet     
% 2. group2-1vs group1-6, 
% same = 



