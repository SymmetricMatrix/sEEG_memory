proj_dir = '/bigvault/Projects/seeg_pointing/results/3dpointing/'

trial_set=[2 4 6 4 6 2 6 2 4 6 4 2 6 4 2 2 6 4 4 2 6 2 4 6 ];

data_summary = struct('turns2', struct('seeg',[],'info',[]),'turns4',struct('seeg',[],'info',[]),'turns6',struct('seeg',[],'info',[]));

for sub_id = 1:27
    subject = ['subject',num2str(sub_id)];
    try
        read_dir = [proj_dir, subject, '/'];
        load([read_dir,subject,'_epoch.mat'])% data_epoch
        load([read_dir,subject,'_channel.mat'])% channel
        
        for turni = [2,4,6]
            turn = find(trial_set==turni);
            data =  reshape(data_epoch(:,turn), [], 1);
            id = ones(size(data))*sub_id;
            turn_name = reshape(repmat(turn, length(channel), 1), [], 1);
            channel_name = reshape(repmat(channel, 1, 8), [], 1);
            info = horzcat(num2cell(id), channel_name,num2cell(turn_name));
            
            % exclude empty
            non_empty_cells = ~cellfun(@isempty, data);
            data = cell2mat(data(non_empty_cells));
            info = info(non_empty_cells,:);
            info = cell2table(info, 'VariableNames', {'sub_id', 'channel', 'trial'});
            % downsample
            if ~ismember(sub_id, [15,17,18,19])
                data = downsample(data',4)';
            end
            
            data_summary.(['turns',num2str(turni)]).seeg = vertcat(data_summary.(['turns',num2str(turni)]).seeg, data);
            data_summary.(['turns',num2str(turni)]).info = vertcat(data_summary.(['turns',num2str(turni)]).info, info);
        end
        
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end
%save([save_dir, subject, '_epoch.mat'], 'data_epoch', '-v7.3');
%%
opt = [];
opt.sfreq = 512;

s_2 = SPRiNT(data_summary.turns2.seeg,opt);
save(['/bigvault/Projects/seeg_pointing/results/3dpointing/machine_learning/s_2.mat'],'s_2', '-v7.3');
s_4 = SPRiNT(data_summary.turns4.seeg,opt);
save(['/bigvault/Projects/seeg_pointing/results/3dpointing/machine_learning/s_4.mat'],'s_4', '-v7.3');
s_6 = SPRiNT(data_summary.turns6.seeg,opt);



%%
color = [75,112,172]/256;
figure
subplot(311)
plot_ci(data_summary.turns2.seeg,color,0.3)
xlim([1,512*51])
xticks(0:512*2:512*51);
xticklabels(0:2:51);
set(gca,'xtick',[])
xline(cumsum([repmat([5 2.5],1,6),5]*512),'Color','r')

subplot(312)
plot_ci(data_summary.turns4.seeg,color,0.3)
xlim([1,512*51])
xticks(0:512*2:512*51);
xticklabels(0:2:51);
set(gca,'xtick',[])
xline(cumsum([repmat([5 2.5],1,6),5]*512),'Color','r')
ylabel('Amplitude');

subplot(313)
plot_ci(data_summary.turns6.seeg,color,0.3)
xlim([1,512*51]);
xticks(0:512*2:512*51);
xticklabels(0:2:51);
xline(cumsum([repmat([5 2.5],1,6),5]*512),'Color','r')

% link the x and y axes of the three subplots
linkaxes([subplot(3,1,1) subplot(3,1,2) subplot(3,1,3)], 'xy')

sgtitle('iEEG signal')

% Add a common xlabel and ylabel to all subplots
xlabel('Time (s)');



%%

location_name = 'Temporal_Mid L';
contacts = readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/contacts.csv','VariableNamingRule','preserve');
[seeg, info] = find_brain_area_seeg(data_summary.turns2, location_name,contacts);


color = [75,112,172]/256;
figure
subplot(311)
plot_ci(find_brain_area_seeg(data_summary.turns2, location_name,contacts),color,0.3)
xlim([1,512*51])
xticks(0:512*2:512*51);
xticklabels(0:2:51);
set(gca,'xtick',[])
xline(cumsum([repmat([5 2.5],1,6),5]*512),'Color','r')

subplot(312)
plot_ci(find_brain_area_seeg(data_summary.turns4, location_name,contacts),color,0.3)
xlim([1,512*51])
xticks(0:512*2:512*51);
xticklabels(0:2:51);
set(gca,'xtick',[])
xline(cumsum([repmat([5 2.5],1,6),5]*512),'Color','r')
ylabel('Amplitude');

subplot(313)
plot_ci(find_brain_area_seeg(data_summary.turns6, location_name,contacts),color,0.3)
xlim([1,512*51]);
xticks(0:512*2:512*51);
xticklabels(0:2:51);
xline(cumsum([repmat([5 2.5],1,6),5]*512),'Color','r')

% link the x and y axes of the three subplots
%linkaxes([subplot(3,1,1) subplot(3,1,2) subplot(3,1,3)], 'xy')

sgtitle(['iEEG signal in ',strrep(location_name, '_', ' ')])

% Add a common xlabel and ylabel to all subplots
xlabel('Time (s)');

    


