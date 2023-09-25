% sequence preprocess
%%
clc
clear
%% general parameter
proj = 'object_recognition';% object_recognition  sequence_memory
%run('/bigvault/Projects/seeg_pointing/0_code/function/sEEG_initialize.m')
% get subjects
ele_excl=readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/label.csv');
home_dir = '/bigvault/Projects/seeg_pointing/';

%% preprocess
for sub_id =20:27 %[1,9,16] 9
    try
        subject = ['subject',num2str(sub_id)];
        save_dir = [home_dir, 'results/', proj, '/', subject, '/'];
        
        % preprocess (data is saved to disk)
        tic
        seeg_pre(sub_id, proj, home_dir, save_dir, ele_excl)
        toc
        
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end
%% rsa
freq =1:46;

for sub_id=1:27
    subject = ['subject',num2str(sub_id)];
    read_dir = fullfile(home_dir,'results',proj,subject,'/');
    save_dir = fullfile(home_dir,'results',proj,subject,'/');
    mkdir(save_dir)
    
    switch proj
        case 'object_recognition'
            data1 = load_mat(fullfile(home_dir,'resluts/object_recognition',subject,[subject, '_sw.mat']));
            data2 = data1;
        case 'sequence_memory'
            data1 = load_mat(fullfile(home_dir,'resluts/sequence_memory',subject,[subject, '_sw.mat']));
            data2 = data1;
            
        case 'obj2seq'
            data1 = load_mat(fullfile(home_dir,'resluts/object_recognition',subject,[subject, '_sw.mat']));
            data2 = load_mat(fullfile(home_dir,'resluts/sequence_memory',subject,[subject, '_sw.mat']));
    end
    
    seeg_rsa( data1, data2, subject, proj, freq, save_dir)
end

%% result check
subject='group';

plot_window=[1 25 1920 1080];

red=[217 83 25]/255;
blue=[0 114 189]/255;
deep_red = [236 43 36]/255;
deep_blue = [29 65 121]/255;


%% Load this subject data into the group
% load group data
load(fullfile(home_dir, 'results', proj, 'rsa_obj_group.mat'))
sub_position = length(rsa_group.sub_id)+1;

rsa_group.same(:,:,sub_position) = rsa;
rsa_group.diff(sub_position) = sub_id;
rsa_group.sub_id(sub_position) = sub_id;


