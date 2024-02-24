
fiff_file = '/bigvault/Projects/seeg_pointing/results/object_recognition/subject7/';
fieldtrip2fiff(fiff_file, data_pre);


 cfg = [];
 cfg.method    = 'convert';
 cfg.datatype  = 'ieeg';
 
 % specify the output directory
 cfg.bidsroot  = '/bigvault/Projects/seeg_pointing/results/object_recognition/subject7/bids';
 cfg.sub       = '07';
 cfg.ses       = 'obj';
 cfg.run       = 1;
 
 % participants info
 cfg.participants.age        = 49
 cfg.participants.sex        = 'm'
 cfg.scans.acq_time          = '2021-12-21T00:00:00' % RFC3339 as '2019-05-22T15:13:38'
 cfg.sessions.acq_time       = '2021-12-21T00:00:00' % RFC3339 as '2019-05-22T15:13:38'
 %cfg.sessions.pathology      = string, recommended when different from healthy
 
% For anatomical and functional MRI data 
cfg.dicomfile               = '/bigvault/Projects/seeg_pointing/subject/subject7/CT_MRI/MRI/MRI_dcm/exported0000.dcm'

data2bids(cfg,data_pre);
%%

%% Template Matlab script to create an BIDS compatible _ieeg.json file
% This example lists all required and optional fields.
% When adding additional metadata please use CamelCase
%
% DHermes, 2017
% modified Jaap van der Aar & Giulio Castegnaro 30.11.18

% Writing json files relies on the JSONio library
% https://github.com/bids-standard/bids-matlab
%
% Make sure it is in the matab/octave path
try
    bids.bids_matlab_version;
catch
    warning('%s\n%s\n%s\n%s', ...
            'Writing the JSON file seems to have failed.', ...
            'Make sure that the following library is in the matlab/octave path:', ...
            'https://github.com/bids-standard/bids-matlab');
end

%%

clear;

this_dir = fileparts(mfilename('fullpath'));
root_dir = fullfile(this_dir, '..', filesep, '..');

project = 'templates';

sub_label = '01';
ses_label = '01';
task_label = 'LongExample';
run_label = '01';

name_spec.modality = 'ieeg';
name_spec.suffix = 'ieeg';
name_spec.ext = '.json';
name_spec.entities = struct('sub', sub_label, ...
                            'ses', ses_label, ...
                            'task', task_label, ...
                            'run', run_label);

% using the 'use_schema', true
% ensures that the entities will be in the correct order
bids_file = bids.File(name_spec, 'use_schema', true);

% Contrust the fullpath version of the filename
json_name = fullfile(root_dir, project, bids_file.bids_path, bids_file.filename);

%% General fields, shared with MRI BIDS and MEG BIDS

% to get the definition of each column,
% you can use the bids.Schema class from bids matlab
% For example
schema = bids.Schema;
def = schema.get_definition('TaskName');
fprintf(def.description);

%% Required fields:
json.TaskName = task_label;
json.SamplingFrequency = [];
json.PowerLineFrequency = [];
json.SoftwareFilters = '';

%% Recommended fields:
HardwareFilters.HighpassFilter.CutoffFrequency = [];
HardwareFilters.LowpassFilter.CutoffFrequency = [];
json.HardwareFilters = HardwareFilters; %

json.Manufacturer = '';
json.ManufacturersModelName = '';
json.TaskDescription = '';
json.Instructions = '';
json.CogAtlasID = 'https://www.cognitiveatlas.org/FIXME';
json.CogPOID = 'http://www.cogpo.org/ontologies/CogPOver1.owl#FIXME';
json.InstitutionName = '';
json.InstitutionAddress = '';
json.DeviceSerialNumber = '';
json.ECOGChannelCount = [];
json.SEEGChannelCount = [];
json.EEGChannelCount = [];
json.EOGChannelCount = [];
json.ECGChannelCount = [];
json.EMGChannelCount = [];
json.MiscChannelCount = [];
json.TriggerChannelCount = [];
json.RecordingDuration = [];
json.RecordingType = '';
json.EpochLength = [];
json.SubjectArtefactDescription = '';
json.SoftwareVersions = '';

%% Specific iEEG fields:

% If mixed types of references, manufacturers or electrodes are used, please
% specify in the corresponding table in the _electrodes.tsv file

%% Required fields:
json.iEEGReference = '';

%% Recommended fields:
json.ElectrodeManufacturer = '';
json.ElectrodeManufacturersModelName = '';
json.iEEGGround = '';
json.iEEGPlacementScheme = '';
json.iEEGElectrodeGroups = '';

%% Optional fields:
json.ElectricalStimulation = '';
json.ElectricalStimulationParameters = '';

%% Write JSON
% Make sure the directory exists
bids.util.mkdir(fileparts(json_name));
bids.util.jsonencode(json_name, json);