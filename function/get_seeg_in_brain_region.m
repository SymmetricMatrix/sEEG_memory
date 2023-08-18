function [selected_data, selected_info]= get_seeg_in_brain_region(data_epoch, sub_id, label_table, brain_region)
% This function finds EEG data for a specific brain region.
% Inputs:
%   data_epoch: cell type, each cell contains a trail (channel * time)
%   sub_id: subject ID
%   label_table: label table form '/bigvault/Projects/seeg_pointing/gather/Tabel/label.csv'
%   brain_region: name of brain region
% Outputs:
%   selected_data: Cell array containing selected EEG data for each trial.
%   selected_info: Table containing labels for the selected channels.

% Find the index of brain_region
channels_selected = table2cell(label_table(label_table.sub_id == sub_id & contains(label_table.AAL3, brain_region), {'label','AAL3','AAL3_prob'}));
channels = channels_selected(:,1);
label_region = check_two_ele(data_epoch.label, channels); % Get the label region using the check_two_ele function
positions = ismember(data_epoch.label, label_region); % Find the positions of the label region in the data_epoch.label array

% select brain_region form each trial
for i = 1:length(data_epoch.trial)
    selected_data{i} = data_epoch.trial{i}(positions, :); % Select the data for the specified brain region
end

% Create table of selected channels.
selected_info = cell2table(channels_selected, 'VariableNames', {'label','AAL3','AAL3_prob'});
id_array = repmat(sub_id, size(selected_info, 1), 1);
selected_info = addvars(selected_info, id_array, 'Before', 1, 'NewVariableNames', 'sub_id');
end
