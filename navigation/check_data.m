
proj = '3dpointing';

% get subjects
pointing=readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/pointing.csv');
home_dir = '/bigvault/Projects/seeg_pointing/';

for sub_id = 1:27
    try
        subject = ['subject',num2str(sub_id)];
        save_dir = [home_dir, 'results/3dpointing/', subject, '/'];
        disp(['-----------',subject,'------------------'])
        sub_dir = dir(fullfile([home_dir,'subject/', subject, '/seeg_edf/', proj], '*.edf'));
        
        
        if ~isempty(sub_dir)
            read_dir = [sub_dir.folder, '/', sub_dir.name];
            header = ft_read_header(read_dir);
            fprintf('EDF start time: %s\n', mat2str(header.orig.T0))
            time_len = table2array(pointing(pointing.sub_id==sub_id & pointing.trial==25, {'end_time'} ));
            time_error = header.nSamples/header.Fs - time_len;
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
%%
kur =[];
for i =1:size(data,1)
    kur(i) = kurtosis(data.seeg{i,1});
    
end
jsonStr = jsonencode(data(kur>5,[1,3,4]));
fid = fopen(['/konglab/home/xicwan/big_data/epilepsy_start.json'], 'w');
fprintf(fid, '%s', jsonStr);
fclose(fid);



