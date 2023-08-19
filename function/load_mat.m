function val = load_mat(load_dir)
% Load .mat file as val
% 
% Inputs:
%   load_dir - directory of the .mat file to load
%
% Output:
%   val - value of the first field in the loaded structure

% Load .mat file from specified directory
val_struct = load(load_dir);
% Get field names of loaded structure
val_names = fieldnames(val_struct);
% Get value of first field in loaded structure
val = val_struct.(val_names{1});
end
