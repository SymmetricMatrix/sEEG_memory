function plt_wavelet_pic18(data)
% plot 18 pictures in wavelet data, freqency 1:30 and time [-2.5, 5]
% Input: data,3D 18*freq*time
for i=1:18
    subplot(3,6,i)
    temp = squeeze(data(i,:,:));
    clim = plt_imagesc(temp,'wavelet_s');
    if i ==1
        climit =clim;
    end
    caxis([-climit,climit])
    colorbar('off')
    title(['pic',num2str(i)])
end
colorbar( 'Position', [.93 .11 .015 .79], 'TickDirection', 'out');
set(gcf, 'Position', [1 25 1920 1080]);
end