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
%proj = 'sequence_memory';% object_recognition  sequence_memory obj2seq
seeg_rsa(subject, proj)


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

