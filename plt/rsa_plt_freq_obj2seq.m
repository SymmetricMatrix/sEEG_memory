function rsa_plt_freq_obj2seq(rsa_same,rsa_diff,subject,plot_window)

figure
subplot(221)
imagesc(mean(rsa_same,3))
yticks(1:2:46);
yticklabels([2:2:29,30:10:119]);
ylabel('Frequence/Hz')
xticks(0:25:200);
xticklabels([-50:25:150]/100);
xlabel('Time/s')
title([subject,': same picture RSA diag'])
temp2=caxis;
colorbar()

subplot(222)
imagesc(mean(rsa_diff,3))
yticks(1:2:46);
yticklabels([2:2:29,30:10:119]);
ylabel('Frequence/Hz')
xticks(0:25:200);
xticklabels([-50:25:150]/100);
xlabel('Time/s')
title([subject,': diffferent picture RSA'])
caxis(temp2)
colorbar()

subplot(223)
imagesc(mean(rsa_same,3)-mean(rsa_diff,3))
yticks(1:2:46);
yticklabels([2:2:29,30:10:119]);
ylabel('Frequence/Hz')
xticks(0:25:200);
xticklabels([-50:25:150]/100);
xlabel('Time/s')
title([subject,': same - diff '])
temp3=caxis;
colorbar()


% t-test same & diff
pic_corr_t=[];
for i=1:size(rsa_diff,1)
    for j=1:size(rsa_diff,2)
        [h,p]=ttest2(rsa_same(i,j,:),rsa_diff(i,j,:));
        pic_corr_t(i,j)=-log(p);
    end
end

subplot(224)
imagesc(pic_corr_t)
yticks(1:2:46);
yticklabels([2:2:29,30:10:119]);
ylabel('Frequence/Hz')
xticks(0:25:200);
xticklabels([-50:25:150]/100);
xlabel('Time/s')
title([subject,':  t-test -log(p) value '])
temp4=caxis;
colorbar()
set(gcf, 'Position', plot_window);
end