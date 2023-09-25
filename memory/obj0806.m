

jjnnclc
clear
%% parameter setting
home_dir='/bigvault/Projects/seeg_pointing/';
proj='object_recognition';

%% RSA
read_dir='/bigvault/Projects/seeg_pointing/results/object_recognition/';

rsa_group =struct('same', [], 'diff', []);
for sub_id=1:17
    subject = ['subject',num2str(sub_id)];
    try
    load([read_dir,subject,'/',subject,'_rsa.mat'])
    rsa_group.same{sub_id,1}=mean(rsa_matrix.same{1,1},3);
    for lag=1:20
        rsa_group.diff{sub_id,lag}=mean(rsa_matrix.diff{1, lag},3); 
    end
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end
save([read_dir,'rsa_group.mat'],'rsa_group')
%% plot object
load([read_dir,'rsa_group.mat'])
same = rsa_group.same;
diff = rsa_group.diff(:,1);
[same,sub_id] = cell2matrix(same);
[diff,sub_id] = cell2matrix(diff);
diff_all=[];
figure
subplot(211)
for i = 1:20
    diff = rsa_group.diff(:,i);
    plot_ci(squeeze(mean(same,2))','r',0.05)
    [diff,sub_id] = cell2matrix(diff);
    plot_ci(squeeze(mean(diff,2))','b',0.05)
    diff_all(:,:,i) = squeeze(mean(diff,2));
end
xlabel('Time/10ms');
ylabel('Corr');
title('Object RSA in same and different(lags) picture');

subplot(212)
data1 = squeeze(mean(same,2))';
data2 = squeeze(mean(diff_all,3))';
plot_ci_sig(data1, data2)
legend('Same','','Diff','','p<0.05')
xlabel('Time/10ms');
ylabel('Corr');
title('Object RSA in same and different(mean) picture');
%% obj2seq region

read_dir='/bigvault/Projects/seeg_pointing/results/sequence_memory/';
rsa_obj2seq_group_trails=[];
rsa_obj2seq_group=[];
for sub_id=1:18
    subject = ['subject',num2str(sub_id)];
    try
    load([read_dir,subject,'/',subject,'_obj_seq_rsa_new.mat'])
    same = rsa.mean.same;
    diff = rsa.mean.diff;
    rsa_obj2seq_group_trails.same{sub_id}=same;
    rsa_obj2seq_group_trails.diff{sub_id}=diff;
    rsa_obj2seq_group.same{sub_id}=mean(same,3);
    rsa_obj2seq_group.diff{sub_id}=mean(diff,3);
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end
save(fullfile(read_dir, ['rsa_obj2seq_group_trails.mat']), 'rsa_obj2seq_group_trails', '-v7.3');
save(fullfile(read_dir, ['rsa_obj2seq_group.mat']), 'rsa_obj2seq_group', '-v7.3');

%%
same = rsa_obj2seq_group.same;
diff = rsa_obj2seq_group.diff;
[same,sub_id] = cell2matrix(same);
[diff,sub_id] = cell2matrix(diff);

figure
data1 = squeeze(mean(same,2))';
data2 = squeeze(mean(diff,2))';
plot_ci_sig(data1, data2)
legend('Same','','Diff','','p<0.05')
xlabel('Time/10ms');
ylabel('Corr');
title('Object RSA in same and different(mean) picture');







%% find hippocamp
label_table=readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/contacts.csv');
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
%% check k>5
k = kurtosis(data_selected);
