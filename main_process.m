% sequence preprocess
%%
clc
clear
%% general parameter
proj = 'sequence_memory';% object_recognition  sequence_memory
run('/bigvault/Projects/seeg_pointing/0_code/initialize/sEEG_initialize.m')
% get subjects
ele_excl=readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/label.csv');
home_dir = '/bigvault/Projects/seeg_pointing/';

sub_id = 17;
subject = ['subject',num2str(sub_id)];
save_dir = [home_dir, 'results/', proj, '/', subject, '/'];

%% preprocess (data is saved to disk)
seeg_pre(sub_id, proj, home_dir, save_dir, ele_excl)

%% rsa
proj = 'obj2seq';% object_recognition  sequence_memory obj2seq
home_dir = '/bigvault/Projects/seeg_pointing/';
freq =1:46;

for sub_id=1:17
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
            data1 = load_mat(fullfile(home_dir,'resluts/object_recognition',subject,[subject, '_sequence_sw.mat']));
            data2 = load_mat(fullfile(home_dir,'resluts/sequence_memory',subject,[subject, '_sequence_sw.mat']));
    end
    
    seeg_rsa( data1, data2, subject, proj, freq, save_dir)
end

%% result check



%% Load this subject data into the group
% load group data
load(fullfile(home_dir, 'results', proj, 'rsa_obj_group.mat'))
sub_position = length(rsa_group.sub_id)+1;

rsa_group.same(:,:,sub_position) = rsa;
rsa_group.diff(sub_position) = sub_id;
rsa_group.sub_id(sub_position) = sub_id;


%% plot
subject='group';

plot_window=[1 25 1920 1080];


red=[217 83 25]/255;
blue=[0 114 189]/255;
deep_red = [236 43 36]/255;
deep_blue = [29 65 121]/255;

