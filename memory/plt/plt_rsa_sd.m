function plt_rsa_sd(data1,data2,type,colormap_name)
% Standard conditions compare the images, and 4 plots will be drawn.
% 1. condition1
% 2. condition2
% 3. condition1-condition2
% 4. ttest of condition1 and condition2
%
% Input: data1, 3D matrix
%        data2, 3dMATRIX
%        Type, type supported by plt_imagesc.m
% Output: figure, 4 subplot

if nargin <4
    cus_map = colormap('parula');
else
    cus_map = othercolor(colormap_name);
end

figure
subplot(2,2,1)
clim = plt_imagesc(mean(data1,3,'omitnan'),type);
colormap(cus_map);

subplot(2,2,2)
plt_imagesc(mean(data2,3,'omitnan'),type);
caxis([-clim,clim]);
colormap(cus_map);

subplot(2,2,3)
plt_imagesc(mean(data1-data2,3,'omitnan'),type);
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


subplot(2,2,4)
plt_imagesc(H.*T,type);
colormap(cus_map);
title('ttest (t-value,where p<0.05)')
set(gcf, 'Position', [1 25 1920 1080]);

end