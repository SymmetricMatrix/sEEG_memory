function [selected_data, selected_info, positions] = get_seeg_in_brain_region(subject, brain_region, data_type, read_dir, label_table)
% This function finds EEG data for a specific brain region.
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

sub_id = str2num(subject(8:end));
load(fullfile(read_dir, subject, [subject, '_channel.mat']), 'channel');

% Find the index of brain_region
channels_selected = table2cell(label_table(label_table.sub_id == sub_id & contains(label_table.AAL3, brain_region), {'label','AAL3','AAL3_prob'}));
channels = channels_selected(:,1);
label_region = check_two_ele(channel, channels); % Get the label region using the check_two_ele function
positions = ismember(channel, label_region); % Find the positions of the label region in the data_epoch.label array

selected_data = [];

switch  data_type
    case 'epoch'
        load(fullfile(read_dir, subject, [subject, '_epoch.mat']), 'data_epoch');
        
        % select brain_region form each trial
        for i = 1:length(data_epoch.trial)
            selected_data{i} = data_epoch.trial{i}(positions, :); % Select the data for the specified brain region
        end

    case 'sw'
        %load(fullfile(read_dir, subject, [subject, '_sw.mat']), 'data_sw');
        data_sw = load_mat(fullfile(read_dir, subject, [subject, '_sequence_sw.mat']));
        
        selected_data = data_sw(positions,:,:,:);
end

% Create table of selected channels.
selected_info = cell2table(channels_selected, 'VariableNames', {'label','AAL3','AAL3_prob'});
id_array = repmat(sub_id, size(selected_info, 1), 1);
selected_info = addvars(selected_info, id_array, 'Before', 1, 'NewVariableNames', 'sub_id');

end
