clc
clear
% Merge all the data at once
%% parameter setting
home_dir='/bigvault/Projects/seeg_pointing/';
save_dir='/bigvault/Projects/seeg_pointing/results/memory_group/';
projs={'object_recognition','sequence_memory','seq_pre_after2','obj2seq'};
sub_ids=1:38;
%%
for proi=2:3
    proj=projs{proi}
    switch proj
        case 'object_recognition'
            read_dir=['/bigvault/Projects/seeg_pointing/results/',proj,'/'];
            rsa_group = struct('same', [], 'diff', [], 'label', struct('same',[],'diff',[]));
            for sub_id=sub_ids
                subject = ['subject',num2str(sub_id)];
                try
                    load([read_dir,subject,'/',subject,'_obj_rsa.mat'])
                    rsa_group.same{sub_id,1}=mean(rsa.same,3);
                    for lag=1:20
                        rsa_group.diff{sub_id,lag}=mean(rsa.diff{1, lag},3);
                    end
                    rsa_group.label.same{sub_id} = rsa.label.same;
                    rsa_group.label.diff{sub_id} = rsa.label.diff;
                    rsa_group.trials{sub_id} = size(rsa.same,3);
                    disp(subject)
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
            save([save_dir,'rsa_obj_group.mat'],'rsa_group')
            
        case {'sequence_memory'}
            read_dir='/bigvault/Projects/seeg_pointing/results/sequence_memory/';
            rsa_group = struct('pic_total', [],'pre_after',[], 'isnr', [],'label', []);
            index = [7,13,25,31,43,49];
            bd = [1:18*3,18*6+1:18*9];
            non_bd = [18*3+1:18*6,18*9+1:18*12];
            bd_id = [index,index+18*6];
            non_bd_id = [index+18*3,index+18*9];
            for sub_id=sub_ids
                subject = ['subject',num2str(sub_id)];
                try
                    load([read_dir,subject,'/',subject,'_seq_rsa.mat'])
                    rsa_group.pic_total{sub_id}=mean(rsa.pic_total,3);
                    rsa_group.pre_after{sub_id}=mean(rsa.pre_after,3);
                    
                    % average rsa for 18 position
                    rsa_types = {'pic_total','pre_after'};
                    for typei = 1:2
                        data_position_bd = [];
                        data_position_non_bd = [];
                        rsa_type = rsa_types{typei};
                        data_bd = rsa.(rsa_type)(:,:,bd);
                        data_non_bd = rsa.(rsa_type)(:,:,non_bd);
                        for pici=1:18
                            data_position_bd(:,:,pici) = mean(data_bd(:,:,pici:18:108),3);
                            data_position_non_bd(:,:,pici) = mean(data_non_bd(:,:,pici:18:108),3);
                        end
                        rsa_group.position.(rsa_type).bd{sub_id}=data_position_bd;
                        rsa_group.position.(rsa_type).non_bd{sub_id}=data_position_non_bd;
                    end
                    
                    rsa_group.isnr.boundary{sub_id}=mean(rsa.isnr.boundary,3);
                    rsa_group.isnr.non_boundary{sub_id}=mean(rsa.isnr.non_boundary,3);
                    
                    rsa_group.label{sub_id} = rsa.label;
                    rsa_group.pic{sub_id} = size(rsa.pic_total,3);
                    disp(subject)
                catch ME
                    % display the error message
                    disp([num2str(sub_id),'----------error-------'])
                    disp(ME.message)
                    % skip the current loop
                    continue
                end
            end
            [rsa_group.pic_total,sub_id] = cell2matrix(rsa_group.pic_total);
            [rsa_group.pre_after,~] = cell2matrix(rsa_group.pre_after);
            
            for typei = 1:length(rsa_types)
                rsa_type = rsa_types{typei};
                rsa_group.position.(rsa_type).bd=cell2matrix(rsa_group.position.(rsa_type).bd);
                rsa_group.position.(rsa_type).non_bd=cell2matrix(rsa_group.position.(rsa_type).non_bd);
            end
            rsa_group.isnr.boundary=cell2matrix(rsa_group.isnr.boundary);
            rsa_group.isnr.non_boundary=cell2matrix(rsa_group.isnr.non_boundary);
            rsa_group.sub_id=sub_id;
            save(fullfile(save_dir, ['rsa_seq_group.mat']), 'rsa_group', '-v7.3');
            
        case {'seq_pre_after2'}
            read_dir='/bigvault/Projects/seeg_pointing/results/sequence_memory/';
            rsa_group =struct('boundary', [],'non_boundary', [], 'label', [],'sub_id',[]);
            for sub_id=sub_ids
                subject = ['subject',num2str(sub_id)];
                try
                    load([read_dir,subject,'/',subject,'_',proj,'_rsa.mat'])
                    rsa_group.boundary{sub_id}=mean(rsa.boundary,3);
                    rsa_group.non_boundary{sub_id}=mean(rsa.non_boundary,3);
                    rsa_group.label.boundary{sub_id} = rsa.label.boundary;
                    rsa_group.label.non_boundary{sub_id} = rsa.label.non_boundary;
                    rsa_group.trials.boundary{sub_id} = size(rsa.label.boundary,3);
                    rsa_group.trials.non_boundary{sub_id} = size(rsa.label.non_boundary,3);
                    disp(subject)
                catch ME
                    % display the error message
                    disp([num2str(sub_id),'----------error-------'])
                    disp(ME.message)
                    % skip the current loop
                    continue
                end
            end
            
            [same,sub_id] = cell2matrix(rsa_group.boundary);
            rsa_group.boundary=same;
            [same,sub_id] = cell2matrix(rsa_group.non_boundary);
            rsa_group.non_boundary=same;
            rsa_group.sub_id=sub_id;
            
            save(fullfile(save_dir, ['rsa_',proj,'_group.mat']), 'rsa_group', '-v7.3');
            
        case {'obj2seq'}
            bd_id = [0,18,18*2,18*6,18*7,18*8];
            non_bd_id = bd_id+18*3;
            read_dir='/bigvault/Projects/seeg_pointing/results/obj2seq/';
            rsa_group =struct('bd', [],'non_bd', [], 'label', []);
            for sub_id=sub_ids
                subject = ['subject',num2str(sub_id)];
                try
                    load([read_dir,subject,'/',subject,'_',proj,'_rsa.mat'])
                    for pici = 1:18
                        bd = find(ismember(rsa.label.same(:,end-1),bd_id+pici));% this is index
                        non_bd = find(ismember(rsa.label.same(:,end-1),non_bd_id+pici));
                        rsa_group.bd{sub_id,pici}=mean(rsa.same(:,:,bd),3);
                        rsa_group.non_bd{sub_id,pici}=mean(rsa.same(:,:,non_bd),3);
                        rsa_group.label.bd{sub_id,pici} = bd;
                        rsa_group.label.non_bd{sub_id,pici} = non_bd;
                    end
                    disp(subject)
                catch ME
                    % display the error message
                    disp([num2str(sub_id),'----------error-------'])
                    disp(ME.message)
                    % skip the current loop
                    continue
                end
            end
            save(fullfile(save_dir, ['rsa_',proj,'_bd.mat']), 'rsa_group', '-v7.3');
    end
end
%% trials
for proi=4
    proj=projs{proi}
    switch proj
        case {'seq_pre_after'}
            read_dir='/bigvault/Projects/seeg_pointing/results/sequence_memory/';
            rsa_group =struct('same', [], 'label', [],'sub_id',[]);
                    disp([num2str(sub_id),'----------error-------'])
                    disp(ME.message)
                    % skip the current loop
                    continue
            for sub_id=sub_ids
                subject = ['subject',num2str(sub_id)];
                try
                    load([read_dir,subject,'/',subject,'_',proj,'_rsa.mat'])
                    same = rsa.same;
                    if sub_id ==4
                        same =  rsa.same(:,:,[1:9*18,10*18+1:13*18]);
                    end
                    rsa_group.same{sub_id}=same;
                    rsa_group.label{sub_id} = rsa.label.same;
                    rsa_group.trials{sub_id} = size(same,3);
                    disp(subject)
                catch ME
                    % display the error message
                    disp([num2str(sub_id),'----------error-------'])
                    disp(ME.message)
                    % skip the current loop
                    continue
                end
            end
            save(fullfile(save_dir, ['rsa_',proj,'_trials.mat']), 'rsa_group', '-v7.3');
    end
end

%% obj2seq boundary vs non_boundary
index = [7,13,25,31,43,49];
bd_id = [index,index+18*6];
non_bd_id = [index+18*3,index+18*9];
for proi=3
    proj=projs{proi}
    switch proj
        case {'obj2seq'}
            read_dir='/bigvault/Projects/seeg_pointing/results/obj2seq/';
            rsa_group =struct('bd', [],'non_bd', [], 'label', []);
            for sub_id=sub_ids
                subject = ['subject',num2str(sub_id)];
                try
                    load([read_dir,subject,'/',subject,'_',proj,'_rsa.mat'])
                    bd = find(ismember(rsa.label.same(:,end-1),bd_id));% this is index
                    non_bd = find(ismember(rsa.label.same(:,end-1),non_bd_id));
                    bd_pre = find(ismember(rsa.label.same(:,end-1),bd_id-1));% this is index
                    non_bd_pre = find(ismember(rsa.label.same(:,end-1),non_bd_id-1));
                    rsa_group.bd{sub_id}=mean(rsa.same(:,:,bd),3);
                    rsa_group.non_bd{sub_id}=mean(rsa.same(:,:,non_bd),3);
                    rsa_group.bd_pre{sub_id}=mean(rsa.same(:,:,bd_pre),3);
                    rsa_group.non_bd_pre{sub_id}=mean(rsa.same(:,:,non_bd_pre),3);
                    rsa_group.label.bd{sub_id} = bd;
                    rsa_group.label.non_bd{sub_id} = non_bd;
                    rsa_group.label.bd_pre{sub_id} = bd_pre;
                    rsa_group.label.non_bd_pre{sub_id} = non_bd_pre;
                    disp(subject)
                catch ME
                    % display the error message
                    disp([num2str(sub_id),'----------error-------'])
                    disp(ME.message)
                    % skip the current loop
                    continue
                end
            end
            [rsa_group.bd,sub_id] = cell2matrix(rsa_group.bd);
            rsa_group.non_bd = cell2matrix(rsa_group.non_bd);
            rsa_group.bd_pre = cell2matrix(rsa_group.bd_pre);
            rsa_group.non_bd_pre = cell2matrix(rsa_group.non_bd_pre);
            rsa_group.sub_id=sub_id;
            save(fullfile(save_dir, ['rsa_',proj,'_bd_old.mat']), 'rsa_group', '-v7.3');
    end
end




bd = (cell2matrix(rsa_group1.bd(:,7))+cell2matrix(rsa_group1.bd(:,13)))/2;
non_bd = (cell2matrix(rsa_group1.non_bd(:,7))+cell2matrix(rsa_group1.non_bd(:,13)))/2;
figure;subplot(1,2,1);imagesc(bd(:,:,1));colorbar();subplot(122);imagesc(rsa_group.bd(:,:,1));colorbar()
(sum(bd == rsa_group.bd));






