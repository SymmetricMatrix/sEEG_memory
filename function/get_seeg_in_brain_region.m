function [data_selected_all, data_fixation_all, selected_info] = get_seeg_in_brain_region(subject, brain_region, data_type, read_dir, label_table, trial_select)
% This function finds EEG data for a specific brain region and trial
% Inputs:
% - subject: a string representing the subject ID.
% - brain_region: a string representing the name of the brain region.
% - data_type: a string representing the type of data to be returned. It can be either 'epoch' or 'sw'.
% - label_table: a table containing information about the labels of the channels.
%
% Outputs:
% - selected_data: a cell array containing the selected EEG data.
% - selected_info: a table containing information about the selected channels.
% - positions: a logical array indicating the positions of the label region in the data_epoch.label array.


% load channel 
sub_id = str2num(subject(8:end));
load(fullfile(read_dir, subject, [subject, '_channel.mat']), 'channel');

% Find that both contacts are at the specified electrode position
channels_selected = table2cell(label_table(label_table.sub_id == sub_id & contains(label_table.AAL3, brain_region), {'label','AAL3','AAL3_prob'}));
channels = channels_selected(:,1);
label_region = check_two_ele(channel, channels); % Get the label region using the check_two_ele function
positions = ismember(channel, label_region); % Find the positions of the label region in the data_epoch.label array
trial_num = length(trial_select);

% if position is empty return empty
if sum(positions)==0 || trial_num < 1
    data_selected_all = [];
    data_fixation_all = [];
    selected_info =[];
    positions = [];
    return
end

% data select
data_selected_all = [];
switch  data_type
    case 'epoch'
        load(fullfile(read_dir, subject, [subject, '_epoch.mat']), 'data_epoch');
        
        % select brain_region form each trial
        for i = 1:length(data_epoch.trial)
            data_selected_all{i} = data_epoch.trial{i}(positions, :); % Select the data for the specified brain region
        end
        
    case 'wavelet'
        time_sw = [3,10.5]; % original [-5.5,8], save [-2.5,5]
        time_fixation = [4.5,5.5];
        chan_selected = find(positions);
        
        % find data and normlized
        % trial_num = length(dir(wavelet_dir))-2;
        %trial_select = 1: length(dir(wavelet_dir))-2;
        
        for triali = 1:trial_num
            data_wavelet = load_mat(fullfile(read_dir, subject, 'wavelet',[num2str(trial_select(triali)), '.mat']));% 1* chan * freq* time
            srate = round(size(data_wavelet.powspctrm,4)/13.5);
            
            % load fixation forsignal power normalize
            data_fixation = squeeze(mean(data_wavelet.powspctrm(1,chan_selected,:,time_fixation(1)*srate+1:time_fixation(2)*srate),4));
            data_select = squeeze(data_wavelet.powspctrm(1,chan_selected,:,time_sw(1)*srate+1:time_sw(2)*srate));
            % fix bug, if the channel only has 1
            if length(chan_selected)==1
                data_fixation = reshape(data_fixation, 1, size(data_fixation,1));
                data_select = reshape(data_select, 1, size(data_select,1), size(data_select,2));
            end
            
%             % normalized for pre fixation
%             chan = length(chan_selected);
%             frex = size(data_select,2);
%
%             for chani =1:chan
%                 for freqi =1:frex
%                     chan_idx = chan_selected(chani);
%                     % all trials cross all conditions
%                     selected_data(chani,freqi,:,triali) = (data_select(chan_idx,freqi,:)-data_fixation(chan_idx,freqi))/data_fixation(chan_idx,freqi);
%                 end
%             end
%

            % downsample to 512 Hz
            down_smaple_factor = srate / 512;
            data_selected_all(:,:,:,triali) = data_select(:,:,1:down_smaple_factor:end);% channnel*frex*time*trails
            data_fixation_all(:,:,triali) = data_fixation;% channnel*frex*trails
        end
end

% Create struct for selected channels, struct('label',{},'position',{});
selected_info = struct('label',[],'position',[]);
channel_info = cell2table(channels_selected, 'VariableNames', {'label','AAL3','AAL3_prob'});
id_array = repmat(sub_id, size(channel_info, 1), 1);
channel_info = addvars(channel_info, id_array, 'Before', 1, 'NewVariableNames', 'sub_id');
selected_info.label = channel_info ;
selected_info.position = chan_selected;
end
