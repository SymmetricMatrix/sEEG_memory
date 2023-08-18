clc
clear
% Merge all the data at once
%% parameter setting
home_dir='/bigvault/Projects/seeg_pointing/';
projs={'object_recognition','sequence_memory'};
proj=projs{1};
%% object_recognition  RSA

read_dir=['/bigvault/Projects/seeg_pointing/results/',proj,'/'];
rsa_group =struct('same', [], 'diff', [], 'label', []);
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

rsa_group.diff_temp = rsa_group.diff;
rsa_group = rmfield(rsa_group, 'diff');
[same,sub_id] = cell2matrix(rsa_group.same);
rsa_group.same=same;
for lag =1:20
    rsa_group.diff{lag}=cell2matrix(rsa_group.diff_temp(:,lag));
end
rsa_group.sub_id=sub_id;
rsa_group = rmfield(rsa_group, 'diff_temp');
save([read_dir,'rsa_obj_group.mat'],'rsa_group')

%% sequence
read_dir='/bigvault/Projects/seeg_pointing/results/sequence_memory/';
rsa_group =struct('same', [], 'label', [],'sub_id',[]);
for sub_id=1:18
    subject = ['subject',num2str(sub_id)];
    try
    load([read_dir,subject,'/',subject,'_seq_rsa.mat'])
    same = rsa.mean.same;
    diff = rsa.mean.diff;
    rsa_group.same{sub_id}=mean(same,3);
    rsa_group.diff{sub_id}=mean(diff,3);
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end

[same,sub_id] = cell2matrix(rsa_group.same);
rsa_group.same=same;
rsa_group.sub_id=sub_id;

%save(fullfile(read_dir, ['rsa_seq_group.mat']), 'rsa_group', '-v7.3');

%%
read_dir='/bigvault/Projects/seeg_pointing/results/sequence_memory/';
rsa_group=[];
for sub_id=1:18
    subject = ['subject',num2str(sub_id)];
    try
    load([read_dir,subject,'/',subject,'_obj_obj2seq_rsa.mat'])
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

[same,sub_id] = cell2matrix(rsa_obj2seq_group.same);
[diff,sub_id] = cell2matrix(rsa_obj2seq_group.diff);
rsa_obj2seq_group.same=same;
rsa_obj2seq_group.diff=diff;
rsa_obj2seq_group.sub_id=sub_id;

save(fullfile(read_dir, ['rsa_obj2seq_group.mat']), 'rsa_obj2seq_group', '-v7.3');