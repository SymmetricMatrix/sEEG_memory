% First, you need to prepare your data in a FieldTrip structure
% Then you can use ft_freqstatistics to compute ITPC
cfg           = [];
cfg.method    = 'wavelet';
cfg.output    = 'fourier';
cfg.foi       = 1:1:15; % specify the frequencies of interest
cfg.toi       = 'all'; % specify the time window of interest
freq          = ft_freqanalysis(cfg, data_epoch);


% make a new FieldTrip-style data structure containing the ITC
% copy the descriptive fields over from the frequency decomposition

%%

index = [7,13,25,31,43,49];
bd_id = [index,index+18*6]; 
non_bd_id = [index+18*3,index+18*9]; 
all=1:216;


for chani=5
figure
subplot(2, 2, 1);
itc = ft_itc(freq,bd_id);
imagesc(itc.time, itc.freq, squeeze(mean(itc.itpc(chani,:,:),1)));
clim = caxis;
title('inter-trial phase coherence');
subplot(2, 2, 3);
imagesc(itc.time, itc.freq, squeeze(mean(itc.itlc(chani,:,:),1)));
title('inter-trial linear coherence');


subplot(2, 2, 2);
itc = ft_itc(freq,non_bd_id);
imagesc(itc.time, itc.freq, squeeze(mean(itc.itlc(chani,:,:),1)));
clim = caxis;
title('inter-trial phase coherence');
subplot(2, 2, 4);
imagesc(itc.time, itc.freq, squeeze(mean(itc.itlc(chani,:,:),1)));
title('inter-trial linear coherence');

for i=1:4
    subplot(2, 2, i)
    xline(5.5,'--')
    xline(8,'--')
    xline(10.5,'--')
    caxis(clim)
    xlim([0,13.5])
    xline(6.5,'--')
    yline(6,'--')
    %xlim([5.5,10.5])
    set(gca, 'YDir', 'reverse');
end
end
sgtitle('all')
%% 18
index = [7,13,25,31,43,49];
bd_id = [index,index+18*6]; 
non_bd_id = [index+18*3,index+18*9]; 
itc = ft_itc(freq,bd_id);

figure
for i=1:18
    subplot(3, 6, i);
    chani=i+36;
    imagesc(itc.time, itc.freq, squeeze(mean(itc.itpc(chani,:,:),1)));
    if i==1
        clim = caxis;
    end
    axis xy
    title('inter-trial phase coherence');
    xline(5.5,'--')
    xline(8,'--')
    xline(10.5,'--')
    caxis(clim)
    xline(6.5,'--')
    yline(6,'--')
    %xlim([5.5,10.5])
    set(gca, 'YDir', 'reverse');
end

sgtitle('all')
%% condition
id=[];
id{1} = [1:18*3,18*6+1:18*9]; % color_id
id{2} = [18*3+1:18*6,18*9+1:18*12]; % non_color_id

figure
for i=1:2
    itc = ft_itc(freq,id{i});
    
    subplot(2, 2, i);
    imagesc(itc.time, itc.freq, squeeze(mean(itc.itpc(:,:,:))));
    axis xy
    title('inter-trial phase coherence');
    xline(5.5,'--')
    xline(8,'--')
    xline(10.5,'--')
    caxis([0,0.2])
    xline(6.5,'--')
    yline(6,'--')
    %xlim([5.5,10.5])
    set(gca, 'YDir', 'reverse');
    
    subplot(2, 2, i+2);
    imagesc(itc.time, itc.freq, squeeze(mean(itc.itlc(:,:,:))));
    axis xy
    title('inter-trial linear coherence');
    xline(5.5,'--')
    xline(8,'--')
    xline(10.5,'--')
    caxis([0,0.2])
    xline(6.5,'--')
    yline(6,'--')
    %xlim([5.5,10.5])
    set(gca, 'YDir', 'reverse');
end

sgtitle('condition: color change vs non color change')
%% position
index = [7,13,25,31,43,49];
bd_id = [index,index+18*6]; 
non_bd_id = [index+18*3,index+18*9]; 

itc_bd = ft_itc(freq,bd_id);
itc_non_bd = ft_itc(freq,non_bd_id);

itpc_bd = permute(itc_bd.itpc,[2,3,1]);
itpc_non_bd = permute(itc_non_bd.itpc,[2,3,1]);
plt_rsa_sd_perm(itpc_bd,itpc_non_bd,'itpc');
[cp, pp, ts, d ] = permutest(itpc_bd,itpc_non_bd, true, 0.05, 100);

mask = nan(size(itpc_bd,[1,2]));
mask(cp{1})=1;
figure
plt_imagesc(mask,'itpc')

id0 = [0,1,2,6,7,8]*18;
cluster_m=[];
for i=1:18
    id = id0+i;
    itc = ft_itc(freq,id);
    itpc =  permute(itc.itpc,[2,3,1]);
    cluster_m{i,1} = caculate_mask_mean(itpc, mask);
    
    itc = ft_itc(freq,id+18*3);
    itpc =  permute(itc.itpc,[2,3,1]);
    cluster_m{i,2} = caculate_mask_mean(itpc, mask);
end
cm(1,:,:) = cell2matrix(cluster_m(:,1));
cm(2,:,:) = cell2matrix(cluster_m(:,2));
cm = permute(cm,[1,3,2]);
figure;
plt_bar_group(cm,{'Boundary','non Boundary'})

for i=1:4
    subplot(2, 2, i)
    xline(5.5,'--')
    xline(8,'--')
    xline(10.5,'--')
    caxis(clim)
    xlim([0,13.5])
    xline(6.5,'--')
    yline(6,'--')
    %xlim([5.5,10.5])
    set(gca, 'YDir', 'reverse');
end

sgtitle('all')
%% 18
index = [7,13,25,31,43,49];
bd_id = [index,index+18*6]; 
non_bd_id = [index+18*3,index+18*9]; 
itc = ft_itc(freq,bd_id);

figure
for i=1:18
    subplot(3, 6, i);
    chani=i+36;
    imagesc(itc.time, itc.freq, squeeze(mean(itc.itpc(chani,:,:),1)));
    if i==1
        clim = caxis;
    end
    axis xy
    title('inter-trial phase coherence');
    xline(5.5,'--')
    xline(8,'--')
    xline(10.5,'--')
    caxis(clim)
    xline(6.5,'--')
    yline(6,'--')
    %xlim([5.5,10.5])
    set(gca, 'YDir', 'reverse');
end

sgtitle('all')
%%
figure
itc = ft_itc(freq,bd_id);
itc_non = ft_itc(freq,non_bd_id);

t=zeros(size(itc.itpc,[2,3]));
h=zeros(size(itc.itpc,[2,3]));
for m=1:size(itc.itpc,2)
    for n=1:size(itc.itpc,3)
        [h(m,n),P,CI,STATS] = ttest(squeeze(itc.itpc(:,m,n)),squeeze(itc_non.itpc(:,m,n)));
        t(m,n) = STATS.tstat;
    end
end
%%
figure
for chani=25:48
    subplot(4, 6, chani-24);
    imagesc(itc.time, itc.freq, squeeze(mean(itc.itpc(chani,:,:),1)));
    clim = caxis;
    title(['ITPC',num2str(chani)]);
    
    xline(5.5,'--')
    xline(8,'--')
    xline(10.5,'--')
    caxis(clim)
    xlim([0,13.5])
    xline(6.5,'--')
    yline(6,'--')
    %xlim([5.5,10.5])
    set(gca, 'YDir', 'reverse');
end
%% 

itc = ft_itc(freq,1:216);

t=zeros(size(itc.itpc,[2,3]));
h=zeros(size(itc.itpc,[2,3]));
for m=1:size(itc.itpc,2)
    for n=1:size(itc.itpc,3)
        [h(m,n),P,CI,STATS] = ttest(squeeze(itc.itpc(:,m,n)));
        t(m,n) = STATS.tstat;

    end
end
figure; imagesc(itc.time, itc.freq, t.*h)
clim = caxis;
caxis([-max(clim),max(clim)]);
%% perm
itpc = permute(itc.itpc,[2,3,1]);
plt_rsa_sd(itpc,zeros(size(itpc)),'itpc');

%% plot phase

index =  [0,1,2,6,7,8]*18;
figure
for i=1:18
itc = ft_itc(freq,index+i);
subplot(3,6,i)
hist(itc.itpc(:,2,floor(8*512)));
title(i)
end
sgtitle('bd,freq=2,time=8*512')

%%
color =lines(57);
figure
subplot(1,2,1)
F = freq.fourierspctrm(bd_id,:,2,floor(8*512));   % copy the Fourier spectrum
% compute inter-trial phase coherence (itpc)
a= F./abs(F);
t = angle(a);
for i=1:57
    theta=t(:,i);
    theta = reshape(theta,1,[]);
    polarplot([zeros(size(theta));theta],[zeros(size(theta));ones(size(theta))], 'color', color(i,:));
    hold on
end
title('bd ,freq=2,time=8*512')

subplot(1,2,2)
F = freq.fourierspctrm(non_bd_id,:,2,floor(8*512));   % copy the Fourier spectrum
% compute inter-trial phase coherence (itpc)
a      = F./abs(F);
t = angle(a);
for i=1:57
    theta=t(:,i);
    theta = reshape(theta,1,[]);
    polarplot([zeros(size(theta));theta],[zeros(size(theta));ones(size(theta))], 'color', color(i,:));
    hold on
end
title('non bd,freq=2,time=8*512')