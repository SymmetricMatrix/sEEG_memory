function ele_label = check_two_ele(ele_bipolar, ele_need)
% This function finds all ele_bipolar label names that contain two elements from the ele_need list.
% Inputs:
%   ele_name_bipolar: ele_pair label name
%   ele_need: ele label we need
% Output:
%   ele_label: satisfied ele_name_pair

ele_label = {}; % Initialize the output variable

for i = 1:length(ele_bipolar) % Loop through each element in ele_name_bipolar
    str_to_check = ele_bipolar{i}; % Get the current string to check
    
    % Split the string into two parts using the "-" delimiter
    str_parts = strsplit(str_to_check, '-');
    
    % Check if both parts are in the cell array
    if ismember(str_parts{1}, ele_need) && ismember(str_parts{2}, ele_need)
        ele_label = [ele_label, str_to_check]; % Add the current string to the output variable
    end
end
