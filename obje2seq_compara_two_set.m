proj = 'obj2seq';
home_dir = '/bigvault/Projects/seeg_pointing/';
bd_id = [0,18,18*2,18*6,18*7,18*8];
non_bd_id = bd_id+18*3;
read_dir='/bigvault/Projects/seeg_pointing/results/obj2seq/';
rsa_group =struct('round1', [],'round2', []);
for sub_id=1:27
    subject = ['subject',num2str(sub_id)];
    try
        load([read_dir,subject,'/',subject,'_',proj,'_rsa.mat'])
       
        bd = find(ismember(rsa.label.same(:,end-1),bd_id+pici));% this is index
        non_bd = find(ismember(rsa.label.same(:,end-1),non_bd_id+pici));
        rsa_group.round1.same{sub_id}=mean(rsa.round.same{1, 1},3);
        rsa_group.round1.diff{sub_id}=mean(rsa.round.diff{1, 1},3);
        rsa_group.round2.same{sub_id}=mean(rsa.round.same{1, 2},3);
        rsa_group.round2.diff{sub_id}=mean(rsa.round.diff{1, 2},3);
        
        disp(subject)
        
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end


%%
[rsa_same,sub_ids] = cell2matrix(rsa_group.round2.same);
rsa_diff = cell2matrix(rsa_group.round2.diff);

rsa_same = rsa.round.same{1, 2};
rsa_diff = rsa.round.diff{1, 2};
figure
plt_rsa_sd(rsa_same,rsa_diff,'obj2seq');

figure

plt_mask(size(rsa_same(66:120,501:700,1)), cp, pp, 1)


% data in the mask
data1 = rsa_same(66:120,501:700,:);
data2 = rsa_diff(66:120,501:700,:);
res_bd =[];
res_non_bd =[];
for chani = 1:size(data1,3)

    res_bd = nanmean(squeeze(data1(:,:,chani)).*mask,[1,2]);
    res_non_bd = nanmean(squeeze(data2(:,:,chani)).*mask,[1,2]);

    result(chani,:) = [res_bd;res_non_bd];
end
figure
plt_box_line(result,{'bd','on bd'})
title(['cluster',num2str(i)])
sum(result(:,1)>result(:,2))
%%
proj = 'obj2seq';
home_dir = '/bigvault/Projects/seeg_pointing/';
bd_id = [0,18,18*2,18*6,18*7,18*8];
non_bd_id = bd_id+18*3;
read_dir='/bigvault/Projects/seeg_pointing/results/obj2seq/';
rsa_group =struct('bd', [],'non_bd', []);
for sub_id=1:27
    subject = ['subject',num2str(sub_id)];
    try
        load([read_dir,subject,'/',subject,'_',proj,'_rsa.mat'])
       
        bd = find(ismember(rsa.label.same(:,end-1),bd_id+pici));% this is index
        non_bd = find(ismember(rsa.label.same(:,end-1),non_bd_id+pici));
        rsa_group.round1.same{sub_id}=mean(rsa.round.same{1, 1},3);
        rsa_group.round1.diff{sub_id}=mean(rsa.round.diff{1, 1},3);
        rsa_group.round2.same{sub_id}=mean(rsa.round.same{1, 2},3);
        rsa_group.round2.diff{sub_id}=mean(rsa.round.diff{1, 2},3);
        
        disp(subject)
        
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end
