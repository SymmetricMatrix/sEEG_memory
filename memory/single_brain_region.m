clc
clear

%% select specific brain region
label_table = readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/contacts.csv');
read_dir = '/bigvault/Projects/seeg_pointing/results/sequence_memory/';
brain_region= 'Hippocampus';
data_type = 'sw';
data_all = [];
info_group = struct('label_prob',[],'position',[]);

for sub_id=1:27
    subject = ['subject',num2str(sub_id)];
    try
        [selected_data, selected_info, positions] = get_seeg_in_brain_region(subject, brain_region, data_type, read_dir, label_table);
        data_all{sub_id} = selected_data;
        info_group.label_prob = vertcat(info_group.label_prob, selected_info);
        info_group.position{sub_id} = positions;
        info_group.selected_num{sub_id} = sum(positions);
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end

save_dir = read_dir;
save(fullfile(save_dir,[brain_region,'_',data_type,'.mat']),'data_all', '-v7.3')
save(fullfile(save_dir,[brain_region,'_',data_type,'_info.mat']),'info_group')

%%
% caculate rsa
obj_region = load_mat(['/bigvault/Projects/seeg_pointing/results/object_recognition/',brain_region,'_',data_type,'.mat']);
seq_region = load_mat(['/bigvault/Projects/seeg_pointing/results/sequence_memory/',brain_region,'_',data_type,'.mat']);

projs = {'object_recognition', 'sequence_memory', 'obj2seq'};
home_dir = '/bigvault/Projects/seeg_pointing/';
freq =1:46;
rsa_group =[];

for sub_id=1:17
    subject = ['subject',num2str(sub_id)];
    for j=1:3
        proj =projs{j};
        try
            switch proj
                case 'object_recognition'
                    data1 = obj_region{sub_id};
                    data2 = data1;
                    rsa = seeg_rsa_output(data1,data2,subject, proj, freq);
                    rsa_group.obj.same{sub_id} = mean(rsa.same,3);
                    for lag =1:20
                        rsa_group.obj.diff{sub_id,lag} = mean(rsa.diff{lag},3);
                    end
                    rsa_group.obj.label{sub_id} = rsa.label;
                    
                case 'sequence_memory'
                    data1 = seq_region{sub_id};
                    data2 = data1;
                    rsa = seeg_rsa_output(data1,data2,subject, proj, freq);
                    rsa_group.seq.same{sub_id} = mean(rsa.same,3);
                    rsa_group.seq.label{sub_id} = rsa.label;
                    
                case 'obj2seq'
                    data1 = obj_region{sub_id};
                    data2 = seq_region{sub_id};
                    rsa = seeg_rsa_output(data1,data2,subject, proj, freq);
                    rsa_group.obj2seq.same{sub_id} = mean(rsa.same,3);
                    rsa_group.obj2seq.diff{sub_id} = mean(rsa.diff,3);
                    rsa_group.obj2seq.label{sub_id} = rsa.label;
            end
        catch ME
            % display the error message
            disp([num2str(sub_id),'----------error-------'])
            disp(ME.message)
            % skip the current loop
            continue
        end
    end
end
%% plot all result

% parameter setting
subject='Hippocampus Group';
plot_window=[1 25 1920 1080];
method = 'sigrank';
fig_export_dir = '/bigvault/Projects/seeg_pointing/results/Hippocampus_Group.pdf';
set(0,'DefaultFigureVisible','on');
%% all cover
plt_text_cover(subject,1:17, plot_window)
export_fig(fig_export_dir, '-pdf','-append','-nocrop');

%% obj data 
[rsa_same, idx] = cell2matrix(rsa_group.obj.same);

plt_text_cover('Object recognition',idx, plot_window)
export_fig(fig_export_dir, '-pdf','-append','-nocrop');

for lag = 1:20
    rsa_diff = cell2matrix(rsa_group.obj.diff(:,lag));
    
    % 1. object same difff
    plt_rsa_obj_sd(rsa_same, rsa_diff, subject, lag, plot_window)
    export_fig(fig_export_dir, '-pdf','-append','-nocrop');
    
    
    % 2. object diag
    plt_rsa_obj_diag(rsa_same,rsa_diff,subject,lag,plot_window)
    export_fig(fig_export_dir, '-pdf','-append','-nocrop');
end
%% seq data
[rsa_seq, idx] = cell2matrix(rsa_group.seq.same);

plt_text_cover('Sequence Memory',idx, plot_window)
export_fig(fig_export_dir, '-pdf','-append','-nocrop');

rsa_seq =tanh(rsa_seq);
% 3. sequence 
plt_rsa_sequence(rsa_seq, subject, plot_window)
export_fig(fig_export_dir, '-pdf','-append','-nocrop');

%% obj2seq data
[rsa_same, idx] = cell2matrix(rsa_group.obj2seq.same);
rsa_diff = cell2matrix(rsa_group.obj2seq.diff);
fig_export_dir = '/bigvault/Projects/seeg_pointing/results/Hippocampus_Group_new.pdf';

plt_text_cover('Obj2Seq',idx, plot_window)
export_fig(fig_export_dir, '-pdf','-append','-nocrop');

% 4. obj2seq same difff
plt_rsa_obj2seq_sd(rsa_same,rsa_diff,subject,plot_window)
export_fig(fig_export_dir, '-pdf','-append','-nocrop');

% 5. obj2seq flatten
plt_rsa_obj2seq_flatten(rsa_same, rsa_diff, 1, subject, plot_window)
export_fig(fig_export_dir, '-pdf','-append','-nocrop');

plt_rsa_obj2seq_flatten(rsa_same, rsa_diff, 2, subject, plot_window)
export_fig(fig_export_dir, '-pdf','-append','-nocrop');

% 6. obj2seq region123
plt_rsa_obj2seq_region123(rsa_same,subject,plot_window,method)
export_fig(fig_export_dir, '-pdf','-append','-nocrop');








%% To rule out possible epileptic discharges
kurtosis(data)

%% event boundary infulence
% 1. wavelet, baseline correct,no smooth,time*freq
% 2. group2-1vs group1-6,
label_table = readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/contacts.csv');
read_dir = '/bigvault/Projects/seeg_pointing/results/sequence_memory/';
brain_region= 'Hippocampus';
data_type = 'wavelet';
read_dir = '/bigvault/Projects/seeg_pointing/results/sequence_memory/';
%info_seq_region = load_mat('/bigvault/Projects/seeg_pointing/results/sequence_memory/Hippocampus_sw_info.mat');
brain_region= 'Hippocampus';
%wavlet_group = [];

% 7, 13
for sub_id = 19
    subject = ['subject',num2str(sub_id)];
    selected_channel = label_table(label_table.sub_id == sub_id & contains(label_table.AAL3, brain_region), {'label'});
    trail_id = event_code(sub_id);
    if ~isempty(selected_channel) & ~isempty(trail_id)
        disp(subject)
        % find index
        trail_id = event_code(sub_id);
        bd_idx = [7, 13, 25, 31, 43, 49];
        bd1 = find(trail_id == 1);
        bd3 = find(trail_id == 3);
        boundary_idx = [bd1(bd_idx); bd3(bd_idx)];
        bd2 = find(trail_id == 2);
        bd4 = find(trail_id == 4);
        non_boundary_idx = [bd2(bd_idx); bd4(bd_idx)];
        before_boundary_idx = boundary_idx -1 ;

        % mean into a subject
        %wavlet_group.boundary{sub_id} = get_seq_wavelet_normalized(read_dir, subject, boundary_idx, selected_channel);
        [selected_data, selected_info, positions] =  get_seeg_in_brain_region(subject, brain_region, data_type, read_dir, label_table,  boundary_idx);
        wavlet_group.boundary{sub_id} = selected_data;
        wavlet_group.non_boundary{sub_id} = get_seeg_in_brain_region(subject, brain_region, data_type, read_dir, label_table, non_boundary_idx);
        wavlet_group.before_boundary{sub_id} = get_seeg_in_brain_region(subject, brain_region, data_type, read_dir, label_table, before_boundary_idx);
        
        wavlet_group.idx.boundary = boundary_idx;
        wavlet_group.idx.non_boundary = non_boundary_idx;
        wavlet_group.idx.before_boundary = before_boundary_idx;
        wavlet_group.idx.channel = positions;
        wavlet_group.idx.info = selected_info;
    
    end
    
end 
%% subject level
for sub_id=1:24
    if ~isempty(wavlet_group.boundary{sub_id})
        wavelet_temp = squeeze(mean(mean(wavlet_group.boundary{sub_id},1),4));
        wavelet_subject.boundary{sub_id}= downsample(wavelet_temp',size(wavelet_temp,2)/7.5/512)';
        wavelet_temp = squeeze(mean(mean(wavlet_group.non_boundary{sub_id},1),4));
        wavelet_subject.non_boundary{sub_id}= downsample(wavelet_temp',size(wavelet_temp,2)/7.5/512)';
        wavelet_temp = squeeze(mean(mean(wavlet_group.before_boundary{sub_id},1),4));
        wavelet_subject.before_boundary{sub_id}= downsample(wavelet_temp',size(wavelet_temp,2)/7.5/512)';
    end
end
    
%%
xlab = [2:29,30:5:115];
xlab_id = 1:5:length(xlab);
[wavelet_boundary,idx] = cell2matrix(wavelet_subject.boundary);
[wavelet_non_boundary,idx] = cell2matrix(wavelet_subject.non_boundary);
[wavelet_before_boundary,idx] = cell2matrix(wavelet_subject.before_boundary);
plt_wavelet_region_bd(wavelet_boundary, wavelet_non_boundary, subject, plot_window)

% 6-7, 12-13

subplot(222)
title([subject,': Before boundary'])

%%

for sub_id=1:27
    subject = ['subject',num2str(sub_id)];
    try
        load(['/bigvault/Projects/seeg_pointing/results/sequence_memory/',subject,'/',subject,'_fixation.mat'])
        
                if any(isnan(data_fixation(:)))
                    disp(subject)
                end
%         
%         disp(subject)
%         load(fullfile(read_dir, subject, [subject, '_channel.mat']), 'channel');
%         
%         % Find the index of brain_region
%         channels_selected = table2cell(label_table(label_table.sub_id == sub_id & contains(label_table.AAL3, brain_region), {'label','AAL3','AAL3_prob'}));
%         channels = channels_selected(:,1)
    catch ME
        % display the error message
        disp([num2str(sub_id),'----------error-------'])
        disp(ME.message)
        % skip the current loop
        continue
    end
end
