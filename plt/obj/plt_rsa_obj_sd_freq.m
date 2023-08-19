function [temp3,temp4] = plt_rsa_obj_sd_freq(rsa_same,rsa_diff,subject,lag,plot_window,temp3,temp4)  
  figure
    subplot(221)
    imagesc(mean(rsa_same,3))
    yticks(1:2:46);
    yticklabels([2:2:29,30:10:119]);
    ylabel('Frequence/Hz')
    xticks(0:25:200);
    xticklabels([-50:25:150]/100);
    xlabel('Time /s')
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
    xlabel('Time /s')
    title([subject,': diffferent picture RSA(lag=',num2str(lag),')'])
    caxis(temp2)
    colorbar()
    
    subplot(223)
    imagesc(mean(rsa_same,3)-mean(rsa_diff,3))
    yticks(1:2:46);
    yticklabels([2:2:29,30:10:119]);
    ylabel('Frequence/Hz')
    xticks(0:25:200);
    xticklabels([-50:25:150]/100);
    xlabel('Time /s')
    title([subject,':  same - diff '])
    if lag ==1
        temp3=caxis;
    else
        caxis(temp3);
    end
    colorbar()
    
    
    % t-test same & diff
    pic_corr_t=[];
    for i=1:size(rsa_diff,1)
        for j=1:size(rsa_diff,2)
            [h,p]=ttest(rsa_same(i,j,:),rsa_diff(i,j,:));
            pic_corr_t(i,j)=-log10(p);
        end
    end
    
    subplot(224)
    imagesc(pic_corr_t)
    yticks(1:2:46);
    yticklabels([2:2:29,30:10:119]);
    ylabel('Frequence/Hz')
    xticks(0:25:200);
    xticklabels([-50:25:150]/100);
    xlabel('Time /s')
    title([subject,':  t-test -log(p) value '])
    if lag ==1
        temp4=caxis;
    else
        caxis(temp4);
    end
    colorbar()
    set(gcf, 'Position', plot_window);
end