% find matrix idx
true_mat = true(18,18);
idx = tril(true_mat,-1);

% code position
design = zeros(18);
design(1:6, 1:6) = 1; 
design(7:12, 7:12) = 1; 
design(13:18, 13:18) = 1; 
position = [design(idx);design(idx)];

% dist1 (6 a group)
a= zeros(6);
for i=1:5
    a(i,i+1:6)=1:6-i;
end
a=a+a';
dist_mat = repmat(a, 3, 3);
dist = [dist_mat(idx);dist_mat(idx)];

% dist1 (18 a group)
a= zeros(18);
for i=1:18
    a(i,i+1:18)=1:18-i;
end
dist_mat = a+a';
dist = [dist_mat(idx);dist_mat(idx)];

% dist2 (each position has unique id)
a = zeros(18, 18);
B = ones(18, 18);
a(find(tril(B,-1))) =1:153;
dist_mat = a+a';
dist = [dist_mat(idx);dist_mat(idx)+153];

% create tabel temp
pos_num = nnz(idx);
condition = [ones(pos_num,1);zeros(pos_num,1)];

tab = [];
rsa18_sum = [];
for sub_id =1:27
    try
    subject = ['subject',num2str(sub_id)];
    load(['/bigvault/Projects/seeg_pointing/results/sequence_memory/',subject,'/',[subject,'_seq_rsa18.mat']])
    bd = mean(seq_rsa18.corr(:,:,:,[1:3,7:9]),4);
    non_bd = mean(seq_rsa18.corr(:,:,:,[4:6,10:12]),4);
    time_len = size(bd,3);
    
    tab_temp = [ones(pos_num*2,1)*sub_id,position,condition,dist];
    tab = [tab;tab_temp];
    
    rsa18 = zeros(pos_num*2,size(bd,3));
    for i=1:time_len
        temp1 = bd(:,:,i);
        temp2 = non_bd(:,:,i);
        rsa18(:,i)=[temp1(idx);temp2(idx)];
    end
    rsa18_sum = [rsa18_sum;rsa18];
 catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end

%% linear mixed model
result_lme = [];
diff =[];
idx1 = find(tab_temp(:,4).*tab_temp(:,2));  % sub_id,position,condition,dist];
idx2 = find(tab_temp(:,4).*(~tab_temp(:,2))); 
idx =[idx1(1:length(idx1)/2);idx2(1:length(idx2)/2);idx1(length(idx1)/2+1:end);idx2(length(idx2)/2+1:end)];
for i=1:time_len
    tbl = table(rsa18_sum(:,i),tab(:,1),tab(:,2),tab(:,3),tab(:,4),'VariableNames',{'rsa','subject','position','condition','dist'});
     for j=1:306
         diff(j,i) = mean(table2array(tbl(tbl.dist==idx(j),1)));
     end
%     lme = fitlme(tbl,'rsa~condition+dist+(1|subject)');
%     temp = dataset2table(lme.Coefficients);
%     result_lme(i,:) = [temp.Estimate;temp.tStat;-log10(temp.pValue)]';
end
%%
figure
imagesc(diff)
yline(45,'--')
yline(153,'--')
yline(197,'--')
xticks(0:50:750);
xticklabels([0:50:750]/100);
xlabel('Time/s')
ylabel('position')
title('seq18 RSA')
%%
[B,I]=sort(diff(:,350));
tab(I,4);
figure
imagesc(diff(I,:))
xticks(0:50:750);
xticklabels([0:50:750]/100);
xlabel('Time/s')
ylabel('position')
title('seq18 RSA')
%%
a = zeros(18, 18);
B = ones(18, 18);
a(find(tril(B,-1))) =1:153;
b=a'+153;
dist_mat = a+triu(b,1);

% figure;imagesc(dist_mat)
data1 = idx(I(end-20:end));
temp = double(ismember(dist_mat,data1));
temp(logical(eye(size(temp)))) = 0.2;
figure;imagesc(temp)
daspect([1 1 1]);
xline(6,'--')
xline(12,'--')
yline(6,'--')
yline(12,'--')
%%
mapcolor = flipud(othercolor('RdBu10'));
figure;
subplot(1,2,1)
data = mean(bd(:,:,301:550),3);
h = imagesc(data);
daspect([1 1 1]);
xline(6,'--')
xline(12,'--')
yline(6,'--')
yline(12,'--')
clim1 = caxis;
colormap(mapcolor)
set(h, 'alphadata', ~isnan(data));
title('bd')
colorbar
subplot(1,2,2)
data = mean(non_bd(:,:,201:250),3);
h2 = imagesc(data);
daspect([1 1 1]);
xline(6,'--')
xline(12,'--')
yline(6,'--')
yline(12,'--')
caxis(clim1);
colormap(mapcolor)
set(h2, 'alphadata', ~isnan(data));
title('non bd')
colorbar
sgtitle('TIme: 301 to 550 ms')
%%
figure;
subplot(1,3,1)
plot(result_lme(:,1:3))
title('beta')
xline(250,'--')
xline(500,'--')
%legend({'Intercept','position','condition','position*condition'})
xlabel('Time/10ms')
ylabel('beta')

subplot(1,3,2)
plot(result_lme(:,4:6))
title('t value')
xline(250,'--')
xline(500,'--')
%legend({'Intercept','position','condition','position*condition'})
xlabel('Time/10ms')
ylabel('t value')

subplot(1,3,3)
plot(result_lme(:,7:9))
xline(250,'--')
xline(500,'--')
title('-log10(p)')
hold on
yline(-log10(0.05),'--')
%legend({'Intercept','position','condition','position*condition'})
legend({'Intercept','condition','dist'})
xlabel('Time/10ms')
ylabel('-log(p)')
%%
imagesc(diff)
title('RSA in different dist')
%xticklabels([1:18])
xlabel('dist')
ylabel('time')


