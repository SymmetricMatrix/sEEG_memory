function [seeg, info] = find_brain_area_seeg(data_struct, location_name,contacts)
% This function finds the brain area in the SEEG data based on the provided
% data structure and location table.
% Inputs:
% - data_struct: a structure have two subfield 'seeg' and 'info'
% - location_name: location name in AAL3
% Output:
% - seeg: a subset of the SEEG data corresponding to the brain areas in the
%   location table

    % Add the split trial information as new variables 'loc1' and 'loc2'
    A = data_struct.info;
    label_split = split(A.trial, '-');
    A = addvars(A, label_split(:,1), label_split(:,2), 'NewVariableNames', {'loc1', 'loc2'});

    location_table = contacts(contains(contacts.AAL3,location_name),{'sub_id','label'});
    % Initialize an index array with zeros to store the brain area matches.
    index = zeros(height(A), 1);

    % Iterate over each row in the data structure.
    for i = 1:height(A)
        sub_id = A.sub_id(i);
        temp_label = location_table.label(location_table.sub_id == sub_id);
        index(i) = ismember(A.loc1(i), temp_label) & ismember(A.loc2(i), temp_label);
    end

    seeg = data_struct.seeg(logical(index), :);
    info = A(logical(index), :);
end