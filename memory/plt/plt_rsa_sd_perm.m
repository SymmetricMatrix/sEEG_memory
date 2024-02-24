function [clusters_perm, p_perm, t_sums_perm, permutation_distribution]= plt_rsa_sd_perm(data1,data2,type,colormap_name)
% Standard conditions compare the images, and 4 plots will be drawn.
% 1. condition1
% 2. condition2
% 3. condition1-condition2
% 4. ttest of condition1 and condition2 and plot cluster after permutation
%
% Input: data1, 3D matrix
%        data2, 3dMATRIX
%        Type, type supported by plt_imagesc.m
% Output: figure, 4 subplot
%
% To run this code you need to install 2 addition package:
% 1. othercolor
% 2. freezeColors / unfreezeColors   https://github.com/jiversen/freezeColors

if nargin <4
    cus_map = colormap('parula');
else
    cus_map = othercolor(colormap_name);
end

figure
subplot(2,2,1)
clim = plt_imagesc(mean(data1,3),type);
colormap(cus_map);

subplot(2,2,2)
plt_imagesc(mean(data2,3),type);
caxis([-clim,clim]);
colormap(cus_map);

subplot(2,2,3)
plt_imagesc(mean(data1-data2,3),type);
colormap(cus_map);


H = [];
P = [];
T = [];
for i=1:size(data1,1)
    for j=1:size(data1,2)
        [H(i,j),P(i,j),~,STATS] =ttest(squeeze(data1(i,j,:)),squeeze(data2(i,j,:)));
        T(i,j)=STATS.tstat;
    end
end


[clusters_perm, p_perm, t_sums_perm, permutation_distribution] = permutest(data1,data2);
% Find the clusters with p_perm < 0.05
significant_clusters = clusters_perm(p_perm < 0.05);

% Plot the significant clusters
hold on;
mask = zeros(size(data1(:,:,1)));
for i = 1:length(significant_clusters)
    mask(significant_clusters{1, i}) = 1;
end
BW_mask = double(bwperim(mask));


subplot(2,2,4)
plt_imagesc(H.*T,type);
colormap(cus_map);
freezeColors;
hold on
cus_map_bd = ones(256,3);
cus_map_bd(131:256,:)=0;
im2 = imagesc(BW_mask);
colormap(cus_map_bd);
im2.AlphaData = 0.2;
freezeColors;
colormap(cus_map);

title('ttest (t-value,where p<0.05)')
set(gcf, 'Position', [1 25 1920 1080]);


for i=1:4
    subplot(2,2,i)
    if ~ismember(type,{'wavelet','wavelet_s','itpc'})
    daspect([1 1 1])
    end
end
end