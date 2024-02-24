% sequence preprocess
% step1 preprocess 
% step2 RSA
% step3 data summarization
%%
clc
clear
%% general parameter
projs ={'object_recognition','sequence_memory'};
proj = projs{2};% object_recognition  sequence_memory
%run('/bigvault/Projects/seeg_pointing/0_code/function/sEEG_initialize.m')
% get subjects
ele_excl=readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/label.csv');
home_dir = '/bigvault/Projects/seeg_pointing/';

%% step1 preprocess
for sub_id =36:38 %[1,9,16] 9
    try
        subject = ['subject',num2str(sub_id)];
        save_dir = [home_dir, 'results/', proj, '/', subject, '/'];
        
        % preprocess (data is saved to disk)
        tic
        seeg_pre(sub_id, proj, home_dir, save_dir, ele_excl)
        toc
        % save sequence cfg(mainly trl) for  pic_pair_obj2seq
        save_seq_cfg(subject)
        
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end
%% step2 rsa
projs = {'object_recognition','sequence_memory','obj2seq'}
for i=3
    proj = projs{i};
    freq =1:46;
    for sub_id=37
        try
            subject = ['subject',num2str(sub_id)];
            read_dir = fullfile(home_dir,'results',proj,subject,'/');
            save_dir = fullfile(home_dir,'results',proj,subject,'/');
            switch proj
                case 'object_recognition'
                    data1 = load_mat(fullfile(home_dir,'results/object_recognition',subject,[subject, '_sw.mat']));
                    data2 = data1;
                case {'sequence_memory'}
                    data1 = load_mat(fullfile(home_dir,'results/sequence_memory',subject,[subject, '_sw.mat']));
                    data2 = data1;
                    save_dir = fullfile(home_dir,'results','sequence_memory',subject,'/');
                case 'obj2seq'
                    data1 = load_mat(fullfile(home_dir,'results/object_recognition',subject,[subject, '_sw.mat']));
                    data2 = load_mat(fullfile(home_dir,'results/sequence_memory',subject,[subject, '_sw.mat']));
            end
            disp(subject)
            seeg_rsa( data1, data2, subject, proj, freq, save_dir)
        catch ME
            % display the error message
            disp([num2str(sub_id),'----------error-------'])
            disp(ME.message)
            % skip the current loop
            continue
        end
    end
end

%% result check
subject='group';

plot_window=[1 25 1920 1080];

red=[217 83 25]/255;
blue=[0 114 189]/255;
deep_red = [236 43 36]/255;
deep_blue = [29 65 121]/255;


%% Load this subject data into the group
% group file named proj_group.mat
for sub_id=27:38
    try
        add_subject_into_group(home_dir, sub_id, proj)
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end


% load group data
load(fullfile(home_dir, 'results', proj, 'rsa_obj_group.mat'))
sub_position = length(rsa_group.sub_id)+1;

rsa_group.same(:,:,sub_position) = rsa;
rsa_group.diff(sub_position) = sub_id;
rsa_group.sub_id(sub_position) = sub_id;

%% caculte sequence task RSA 18*18
result_dir = '/bigvault/Projects/seeg_pointing/results/sequence_memory';
seq_sw = [];
for sub_id=1:27
    subject = ['subject',num2str(sub_id)];
    try
        subject = ['subject',num2str(sub_id)];
        read_dir = fullfile(result_dir,subject,[subject,'_sw.mat']);
        save_dir = fullfile(result_dir,subject);
        disp(subject)
        load(read_dir,'data_sw')
        seq_sw(sub_id,:)=size(data_sw);
        
        [seq_r,seq_p] = calculate_seq_rsa(data_sw(:,:,:,end-215:end));
        seq_rsa18 = [];
        seq_rsa18.corr = seq_r;
        seq_rsa18.pvalue = seq_p;
        
        save(fullfile(save_dir, [subject, '_seq_rsa18.mat']), 'seq_rsa18', '-v7.3');
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end
save('/bigvault/Projects/seeg_pointing/results/memory_group/seq_sw_size.mat', 'seq_sw');
%% subject channel add probability
contacts=readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/contacts.csv');
result_dir = '/bigvault/Projects/seeg_pointing/results/sequence_memory';
for sub_id=1:27
    subject = ['subject',num2str(sub_id)];
    try
        
        read_dir = fullfile(result_dir,subject,[subject,'_channel.mat']);
        save_dir = fullfile(result_dir,subject);
        disp(subject)
        load(read_dir,'channel')

        sub_tabel = contacts(contacts.sub_id == sub_id,{'lab_bs','MNI','AAL3','AAL3_prob','HCPex','HCPex_MNI_linear__prob'});
        for i=40:length(channel)
            contact1 = extractBefore(channel{i}, '-');
            channel(i,2:7) = table2cell(sub_tabel(strcmp(sub_tabel.lab_bs, contact1),{'lab_bs','MNI','AAL3','AAL3_prob','HCPex','HCPex_MNI_linear__prob'}));
            contact2 = extractAfter(channel{i}, '-');
            channel(i,8:13) = table2cell(sub_tabel(strcmp(sub_tabel.lab_bs, contact2),{'lab_bs','MNI','AAL3','AAL3_prob','HCPex','HCPex_MNI_linear__prob'}));
        end
        save(fullfile(save_dir, [subject, '_channel_summary.mat']), 'channel');
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end
%% change hipp_info
hipp = load_mat('/bigvault/Projects/seeg_pointing/results/memory_group/hipp_info');
hipp_info = num2cell(hipp);
sub_ids = unique(hipp_info(:,1));
for i = 1:length(sub_ids)
    sub_id = sub_ids(i);
    subject = ['subject',num2str(sub_id)];
    read_dir = fullfile(result_dir,subject,[subject,'_channel.mat']);
    save_dir = fullfile(result_dir,subject);
    disp(subject)
    load(read_dir,'channel')
    
    idx = find(hipp(:,1)==sub_id);
    hipp_info(idx,4:16) = channel(hipp(idx,2),:);
    
end




idx1 = (cell2mat(hipp_info(:,8))>0.25)&(cell2mat(hipp_info(:,14))>0.25)
%idx2 =  contains(hipp_info(:,9),'Hippocampus');
%idx3 =  contains(hipp_info(:,15),'Hippocampus');
idx = idx1 ;
hipp_temp = hipp_info(idx,:);

wavelet_channel.info = hipp_temp;
wavelet_channel.kurt  = wavelet_channel1.kurt(idx,:);
wavelet_channel.data_bd  = wavelet_channel1.data_bd(idx,:);
wavelet_channel.data_non_bd  = wavelet_channel1.data_non_bd(idx,:);





