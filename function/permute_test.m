%% built-in function: permutest
tic; 
[clusters, p_values, t_sums, permutation_distribution ] = permutest(rsa_same_group,rsa_diff_group);
toc

figure
clusters=permutest_group.clusters;
a = zeros(size(rsa_same_group,1),size(rsa_same_group,2));
for i=1:10
    a(clusters{1,i})=i;
end
imagesc(a)
yticks(0:10:120);
yticklabels([0:10:120]/100);
ylabel('Object pic /s')
xticks(0:50:700);
xticklabels([-200:50:500]/100);
xlabel('Sequence pic /s')
title([subject,': Permutation '])
colorbar()
xline(460,'-');
xline(470,'-')

xline(440,'-')
%%
% make null distribution
perm_num=1000;
same_diff_null=[];
for sub_id = 1:18
    subject = strcat('subject', num2str(sub_id));
    try
        load(['/bigvault/Projects/seeg_pointing/results/sequence_memory/',subject,'/',subject,'_obj_seq_rsa.mat'])
        
        for  permi=1:perm_num
            pics = size(rsa.mean.same,3);
            merge_matrix = cat(3, rsa.mean.same,rsa.mean.diff);
            perm_idx = randperm(pics*2);% get perm idx
            same_diff_null{sub_id}(:,:,permi) = mean(merge_matrix(:,:,perm_idx(1:pics))-merge_matrix(:,:,perm_idx(pics+1:pics*2)),3);
        end
        disp([num2str(sub_id),'  done'])
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end


save(['/bigvault/Projects/seeg_pointing/results/sequence_memory/same_diff_null.mat'],'same_diff_null','-v7.3');


%%
%%
% make null distribution --object
perm_num=1000;
same_diff_null=[];
for sub_id = 1:18
    % subject = strcat('subject', num2str(sub_id));
    try
        % load(['/bigvault/Projects/seeg_pointing/results/sequence_memory/',subject,'/',subject,'_obj_seq_rsa.mat'])
        for lag =1:20
            same = rsa_all.same{sub_id};
            diff =rsa_all.diff{sub_id, 1}{1, lag}  ;
            pics = size(same,3);
            merge_matrix = cat(3, same, diff);
            for  permi=1:perm_num
                perm_idx = randperm(pics*2);% get perm idx
                same_diff_null{sub_id,lag}(:,:,permi) = mean(merge_matrix(:,:,perm_idx(1:pics))-merge_matrix(:,:,perm_idx(pics+1:pics*2)),3);
            end
        end
        disp([num2str(sub_id),'  done'])
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end

save(['/bigvault/Projects/seeg_pointing/results/object_recognition/same_diff_null.mat'],'same_diff_null','-v7.3');

%% plot sequence

        rsa_same = rsa.mean.same;
        rsa_diff = rsa.mean.diff;
        
        % plot same and different  and t value
        rsa_plt_sd_obj2seq(rsa_same,rsa_diff,subject,plot_window)
        export_fig(fig_export_dir, '-pdf','-append','-nocrop');
        
        % plot Sequence
        rsa_plt_time_obj2seq(rsa_same,rsa_diff,2,subject,plot_window)
        export_fig(fig_export_dir, '-pdf','-append','-nocrop');
        
        % plot Sequence
        rsa_plt_time_obj2seq(rsa_same,rsa_diff,1,subject,plot_window)
        export_fig(fig_export_dir, '-pdf','-append','-nocrop');
        
        disp([num2str(sub_id),': done'])





%%
rsa_same=mean(rsa_same,3);
rsa_diff=mean(rsa_diff,3);
% excute 
z_threshold = 1.64; 
% p = 0.05 for one-tailed
mcc_pval = 0.05;
do_zscore = 1;
tail = 1; % upper-tail

[x_zscored, h0_zscore, zmapthresh] = super_subject_cluster_test(mean(rsa_same-rsa_diff,3), same_diff_null{1}, z_threshold, mcc_pval, tail, do_zscore);