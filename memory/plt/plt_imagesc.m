function clim = plt_imagesc(data,type)
% plot all kinds of imagesc plot for memory task
% Input: data,            2D maxtrix
%        type,            'obj',obj2seq', 'pic _total', 'pre_after'
% Output: plot imagesc,   Not a new figure
%         clim,           return caixs of this plot

switch type
    case 'obj'
        imagesc(data)
        yticks(0:25:200);
        yticklabels([-50:25:150]/100);
        ylabel('1st present pic /s')
        xticks(0:25:200);
        xticklabels([-50:25:150]/100);
        hold on
        xline(50,'--')
        xline(165,'--')
        yline(50,'--')
        yline(165,'--')
        xlabel('2nd present pic /s')
        title(['Object RSA'])
    case 'obj2seq'
        imagesc(data)
        yticks(0:20:200);
        yticklabels([-50:20:150]/100);
        ylabel('Object pic /s')
        yline(50,'--')
        yline(165,'--')
        xticks(0:50:750);
        xticklabels([-250:50:500]/100);
        xlabel('Sequence pic /s')
        xline(250,'--')
        xline(500,'--')
        title(['Obj2Seq RSA'])
     case 'obj2seq_s'
        imagesc(data)
        yticks(0:20:115);
        yticklabels([0:20:115]/100);
        ylabel('Object pic /s')
        xticks(0:50:500);
        xticklabels([0:50:500]/100);
        xlabel('Sequence pic /s')
        xline(250,'--')
        title(['Obj2Seq RSA'])
    case 'obj2seq_pic'
        imagesc(data)
        yticks(0:20:115);
        yticklabels([0:20:115]/100);
        ylabel('Object pic /s')
        xticks(0:50:250);
        xticklabels([0:50:250]/100);
        xlabel('Sequence pic /s')
        title(['Obj2Seq picture RSA'])
    case 'obj2seq_maintain'
        imagesc(data)
        yticks(0:20:115);
        yticklabels([0:20:115]/100);
        ylabel('Object pic /s')
        xticks(0:50:250);
        xticklabels([250:50:500]/100);
        xlabel('Sequence pic /s')
        title(['Obj2Seq maintain RSA'])
    case 'pic_total'
        imagesc(data); % plot the RSA sequence as an image
        yticks(0:25:250);
        yticklabels([0:25:250]/100); % set y-axis tick labels
        ylabel('Picture Present/s')
        xticks(0:25:750);
        xticklabels([-250:25:500]/100); % set x-axis tick labels
        xlabel('Total Trial /s')
        title('Pic Present vs Total RSA') % set the title of the plot
    case 'pre_after'
        imagesc(data); % plot the RSA sequence as an image
        yticks(0:20:200);
        yticklabels([-250:20:-50]/100); % set y-axis tick labels
        ylabel('Pre ITI/s')
        xticks(0:20:200);
        xticklabels([250:20:450]/100); % set x-axis tick labels
        xlabel('Current ITI/s')
        title('Sequence RSA Pre vs After') % set the title of the plot
    case 'wavelet'
        imagesc(data);
        yticks(0:20:120);
        yticklabels([0:20:120]);
        ylabel('Frequency /Hz');
        xticks(0:256:7.5*512);
        xticklabels([0:256:7.5*512]/512);
        xlabel('Sequence pic /s')
        xline(2.5*512,'--')
        xline(5*512,'--')
        colorbar()
    case 'wavelet_s'
        imagesc(data);
        yticks(0:5:120);
        yticklabels([0:5:120]);
        ylabel('Frequency /Hz');
        xticks(0:256:7.5*512);
        xticklabels([0:256:7.5*512]/512);
        xlabel('Time /s')
        xline(2.5*512,'--')
        xline(5*512,'--')
        colorbar()
    case 'itpc'
        imagesc(data);
        yticks(0:3:15);
        yticklabels([0:3:15]);
        ylabel('Frequency /Hz');
        xticks(0:256:13.5*512);
        xticklabels([-5.5*512:256:8*512]/512);
        xlabel('Time /s')
        xline(5.5*512,'--')
        xline(8*512,'--')
        xline(10.5*512,'--')
        colorbar()

end
% set gener parmeter, caxis and colorbar
temp=caxis;
clim = max(abs(temp));
caxis([-clim,clim]);
if strcmp(type,'itpc')
    caxis([0,clim]);
end
colorbar()


end