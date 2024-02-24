function plt_model(modal_temp,time_idx,type,color)
% plot the hist of frequency detected by Modal.

trials_num = length(unique(modal_temp.channel))*length(unique(modal_temp.trial));%size(unique(modal_temp(:, [1,3,4]), 'rows'),1);
freq = squeeze(cell2matrix(modal_temp.frequency_sliding))';
freq = freq(:,time_idx);% signal* time
freq_bands(:,1) = min(freq');
freq_bands(:,2) = max(freq');
freq_bands = round(freq_bands);

switch type
    case 'hist'
        % plot the frequency of each frequency band, one trial count one
        % time
        bands_all = [];
        for i=1:size(modal_temp,1)
            bands_all = [bands_all,freq_bands(i,1):freq_bands(i,2)];
        end
        bin_values = histcounts(bands_all, 'BinEdges', [0:1:30]);
        normalized_values = bin_values / trials_num;
        % Plot the updated histogram
        b=bar([0:1:29], normalized_values,'FaceColor',color);
        alpha(b, 0.4);
        ylabel('MODAL detect rate');
        xlabel('Frequency')
    case 'count'
        % plot the frequency of each frequency band, count for each time
        count_range = floor([min(freq(:)),max(freq(:))]);
        k=1;
        ttemp = squeeze(cell2matrix(modal_temp.bandpow))';
        ttemp = ttemp(:,time_idx);
        for i=count_range(1):count_range(2)
            freq_mat =  double((freq>=i)&(freq<i+1));
            freq_mat(freq_mat==0) = nan;
            tt = freq_mat.*ttemp;
            %count_data(k,:) = abs(mean(exp(1i*tt),'omitnan'));
            count_data(k,:) = sum(tt,'omitnan')/trials_num;
            k=k+1;
        end
        disp(['count range is: ', num2str(count_range(1)),' to ', num2str(count_range(2))])
        imagesc(count_data)
        yticks(1:3:k);
        yticklabels(count_range(1):3:count_range(2));
        ylabel('Frequency /Hz');
        xticks(0:256:13.5*512);
        xticklabels([0:256:13.5*512]/512);
        xlabel('Time/s')
    case 'power'
        % plot the power for detected 
        pow = squeeze(cell2matrix(modal_temp.bandpow))';
        pow = pow(:,time_idx);% signal* time
        count_range = floor([min(freq(:)),max(freq(:))]);
        k=1;
        for i=count_range(1):count_range(2)
            temp = ((freq>=i)&(freq<i+1)).*pow;
            temp(temp==0)=nan;
            count_data(k,:) = mean(temp,'omitnan');
            k=k+1;
        end
        disp(['count range is: ', num2str(count_range(1)),' to ', num2str(count_range(2))])
        imagesc(count_data)
        yticks(1:3:k);
        yticklabels(count_range(1):3:count_range(2));
        ylabel('Frequency /Hz');
        xticks(0:256:7.5*512);
        xticklabels([0:256:7.5*512]/512);
        xlabel('Time/s')
end
end
