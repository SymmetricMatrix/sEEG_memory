% load Tables
contacts=readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/contacts.csv');
ele_excl=readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/label.csv');

% bisic parameter
range = [0.1,250];% intersted frequency, for prepocess

% find subjects
switch proj
    case "3dpointing"
        pointing=readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/pointing.csv');
        diary /bigvault/Projects/seeg_pointing/0_code/initialize/pointing_log.txt

    case "object_recognition"
        diary /bigvault/Projects/seeg_pointing/0_code/initialize/pointing_log.txt
        
    case "sequence_memory"
        diary /bigvault/Projects/seeg_pointing/0_code/initialize/sequence_log.txt
end

% off warning
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames')

% home dir
home_dir = '/bigvault/Projects/seeg_pointing/subject/';
save_dir = ['/bigvault/Projects/seeg_pointing/results/',proj,'/'];

echo off 
fprintf('--------------------------------------------\n');
fprintf(['Record time:  ', datestr(now)]);





