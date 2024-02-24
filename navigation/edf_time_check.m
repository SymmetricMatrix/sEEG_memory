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


error=[];
for sub_id = 1:38
    try
        subject = ['subject',num2str(sub_id)];
        sub_dir = dir(fullfile([home_dir,'subject/', subject, '/seeg_edf/', proj], '*.edf'));
        
        if ~isempty(sub_dir)
            read_dir = [sub_dir.folder, '/', sub_dir.name];
            
            header = ft_read_header(read_dir);
            srate = header.Fs;  
            time_len = table2array(pointing(pointing.sub_id==sub_id & pointing.trial==25, {'end_time'} ));
            time_error = header.nSamples/srate - time_len;
            error(sub_id)=time_error;
            %error{sub_id,1}=time_error;
            %error{sub_id,2}=header.orig.T0  ;
            disp([subject,' time error is: ',num2str(time_error)])
        end
        
        
        
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end