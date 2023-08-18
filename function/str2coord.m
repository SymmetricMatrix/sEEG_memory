function numCoords=str2coord(coords)
% coords = contacts.MNI; % example coordinates column
coords = cellfun(@(x) strrep(x, '[', ''), coords, 'UniformOutput', false); % remove opening bracket
coords = cellfun(@(x) strrep(x, ']', ''), coords, 'UniformOutput', false); % remove closing bracket
splitCoords = cellfun(@(x) strsplit(x,','), coords, 'UniformOutput', false); % split into separate strings
numCoords = cellfun(@(x) cellfun(@str2double, x), splitCoords, 'UniformOutput', false); % convert strings to numbers
numCoords = cell2mat(numCoords); % convert to numeric array
end  