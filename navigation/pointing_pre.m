% 3d pointing
%%
clc
clear
%% general parameter
proj = '3dpointing';

% get subjects
ele_excl=readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/label.csv');
pointing=readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/pointing.csv');
home_dir = '/bigvault/Projects/seeg_pointing/';

% sub_ids 
sub_ids = table2array(unique(pointing(~isnan(pointing.error),{'sub_id'})));
% delete subject 5 and 11
idx = ~(sub_ids == 5 | sub_ids == 11);
sub_ids = sub_ids(idx);

for sub_id = 30
    try
        subject = ['subject',num2str(sub_id)];
        save_dir = [home_dir, 'results/3dpointing/', subject, '/'];
        mkdir(save_dir)

        sub_dir = dir(fullfile([home_dir,'subject/', subject, '/seeg_edf/', proj], '*.edf'));
        
        % preprocess (data is saved to disk)
        tic
        if ~isempty(sub_dir)
            read_dir = [sub_dir.folder, '/', sub_dir.name];
            
            % change edf label name, filter & bipolar
            channels = table2cell(ele_excl(ele_excl.sub_id == sub_id & ele_excl.lab_inside == 1, {'label'}));
            channels_bs = table2cell(ele_excl(ele_excl.sub_id == sub_id & ele_excl.lab_inside == 1, {'lab_bs'}));
            
            data_pre = pre_filter(read_dir, channels, channels_bs);
            channel = data_pre.label;
            save([save_dir, subject, '_pre.mat'], 'data_pre', '-v7.3');
            save([save_dir, subject, '_channel.mat'], 'channel', '-v7.3');
        end
        toc
        
        % epoch data
        data_epoch=cell(length(channel),24);
        srate = data_pre.fsample;
        data=data_pre.trial{1};
        time=pointing(pointing.sub_id==sub_id & ~isnan(pointing.error), {'start_time','end_time'});
        time=table2array(time);
        time_idx=[(time(:,1)-1)*srate+1,time(:,2)*srate];
        % check time 
        time_len = table2array(pointing(pointing.sub_id==sub_id & pointing.trial==25, {'end_time'} ));
        time_error = length(data_pre.time{1,1})/srate - time_len;
        disp([subject,' time error is: ',num2str(time_error)])
        if abs(time_error)<10
            for i=1:size(time_idx,1)
                if isnan(time_idx(i,1))
                    i=i+1;
                    continue;
                end
                data_epoch(:,i)=num2cell(data(:,time_idx(i,1):time_idx(i,2)),2);
            end
        else 
            disp([subject,'   time index is wrong'])
        end
        save([save_dir, subject, '_epoch.mat'], 'data_epoch', '-v7.3');
        
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end