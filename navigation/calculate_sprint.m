function [s_512, s_2048] = calculate_sprint(data, location_name)
    % This function calculates SPRiNT for the given location in the given data.
    % Input:
    % - data_same_region: A table containing SEEG data for the same region.
    % - location_name: A string containing the name of the location to calculate SPRiNT for.
    % Output:
    % - s_512: A matrix containing SPRiNT values for srate=512.
    % - s_2048: A matrix containing SPRiNT values for srate=2048.

    % Select the data for the given location.
    data_region = data(strcmp(data.location1, location_name), :);

    % Calculate the length of each cell in the SEEG data.
    cell_lengths = zeros(size(data_region.seeg));
    for i = 1:numel(data_region.seeg)
        cell_lengths(i) = length(data_region.seeg{i});
    end
    
    % Select the data with cell length 3584 for srate=512.
    s_512= [];
    data_region_512 = data_region(cell_lengths==3584,:);
    seeg = cell2mat(table2array(data_region_512(:, 'seeg')));
    if ~isempty(seeg)
        opt = [];
        opt.sfreq = 512;
        s_512 = SPRiNT(seeg,opt);
    end
    
    % Select the data with cell length 14336 for srate=2048. 
    s_2048 = [];
    data_region_2048 = data_region(cell_lengths==14336,:);
    seeg = cell2mat(table2array(data_region_2048(:, 'seeg')));
    if ~isempty(seeg)
        opt = [];
        opt.sfreq = 2048;
        s_2048 = SPRiNT(seeg,opt);
    end
end