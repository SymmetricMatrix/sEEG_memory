clc
clear

%% select specific brain region
label_table = readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/contacts.csv');
read_dir = '/bigvault/Projects/seeg_pointing/results/sequence_memory/';
brain_region= 'Hippocampus';
data_type = 'sw';
data_all = [];
info_group = struct('label_prob',[],'position',[]);

for sub_id=1:17
    subject = ['subject',num2str(sub_id)];
    try
        [selected_data, selected_info, positions] = get_seeg_in_brain_region(subject, brain_region, data_type, read_dir, label_table);
        data_all{sub_id} = selected_data;
        info_group.label_prob = vertcat(info_group.label_prob, selected_info);
        info_group.position{sub_id} = positions;
        info_group.selected_num{sub_id} = sum(positions);
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

%%
% caculate rsa
obj_region = load_mat(['/bigvault/Projects/seeg_pointing/results/object_recognition/',brain_region,'_',data_type,'.mat']);
seq_region = load_mat(['/bigvault/Projects/seeg_pointing/results/sequence_memory/',brain_region,'_',data_type,'.mat']);

projs = {'object_recognition', 'sequence_memory', 'obj2seq'};
home_dir = '/bigvault/Projects/seeg_pointing/';
freq =1:46;
rsa_group =[];

for sub_id=1:17
    subject = ['subject',num2str(sub_id)];
    for j=1:3
        proj =projs{j};
        try
            switch proj
                case 'object_recognition'
                    data1 = obj_region{sub_id};
                    data2 = data1;
                    rsa = seeg_rsa_output(data1,data2,subject, proj, freq);
                    rsa_group.obj.same{sub_id} = mean(rsa.same,3);
                    for lag =1:20
                        rsa_group.obj.diff{sub_id,lag} = mean(rsa.diff{lag},3);
                    end
                    rsa_group.obj.label{sub_id} = rsa.label;
                    
                case 'sequence_memory'
                    data1 = seq_region{sub_id};
                    data2 = data1;
                    rsa = seeg_rsa_output(data1,data2,subject, proj, freq);
                    rsa_group.seq.same{sub_id} = mean(rsa.same,3);
                    rsa_group.seq.label{sub_id} = rsa.label;
                    
                case 'obj2seq'
                    data1 = obj_region{sub_id};
                    data2 = seq_region{sub_id};
                    rsa = seeg_rsa_output(data1,data2,subject, proj, freq);
                    rsa_group.obj2seq.same{sub_id} = mean(rsa.same,3);
                    rsa_group.obj2seq.diff{sub_id} = mean(rsa.diff,3);
                    rsa_group.obj2seq.label{sub_id} = rsa.label;
            end
        catch ME
            % display the error message
            disp([num2str(sub_id),'----------error-------'])
            disp(ME.message)
            % skip the current loop
            continue
        end
    end
end
%% plot all result

% parameter setting
subject='Hippocampus Group';
plot_window=[1 25 1920 1080];
method = 'sigrank';

%% obj data 
[rsa_same, idx] = cell2matrix(rsa_group.obj.same);
lag = 1;
rsa_diff = cell2matrix(rsa_group.obj.diff(:,lag));

% 1. object same difff
plt_rsa_obj_sd(rsa_same, rsa_diff, subject, lag, plot_window)

% 2. object diag
plt_rsa_obj_diag(rsa_same,rsa_diff,subject,lag,plot_window)

%% seq data
rsa_seq = cell2matrix(rsa_group.seq.same);
% rsa_seq =tanh(rsa_seq);
% 3. sequence 
plt_rsa_sequence(rsa_seq, subject, plot_window)

%% obj2seq data
[rsa_same, idx] = cell2matrix(rsa_group.obj2seq.same);
rsa_diff = cell2matrix(rsa_group.obj2seq.diff);

% 4. obj2seq same difff
plt_rsa_obj2seq_sd(rsa_same,rsa_diff,subject,plot_window)

% 5. obj2seq flatten
plt_rsa_obj2seq_flatten(rsa_same, rsa_diff, 1, subject, plot_window)

plt_rsa_obj2seq_flatten(rsa_same, rsa_diff, 2, subject, plot_window)

% 6. obj2seq region123
plt_rsa_obj2seq_region123(rsa_same,subject,plot_window,method)




%% To rule out possible epileptic discharges
kurtosis(data)

%% event boundary infulence
% 1. wavelet, baseline correct,no smooth,time*freq
% 2. group2-1vs group1-6,

% select data
% sequence  

% 6-7, 12-13


% 7, 13


