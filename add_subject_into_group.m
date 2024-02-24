function add_subject_into_group(home_dir, sub_id, proj)
% Adds subject data to a group-level RSA analysis for a given project.
%
% Inputs:
% - home_dir: the directory containing the project data
% - sub_id: the ID of the subject to add
% - proj: the name of the project ('object_recognition', 'sequence_memory', or 'obj2seq')
%
% Outputs: 
%  rsa_obj_group {same, diff, label ,sub_id} diff has 20
%  rsa_seq_group {same, label ,sub_id} 
%  rsa_obj2seq_group {same, diff, label ,sub_id} diff has 20
subject = ['subject',num2str(sub_id)];

switch proj
    case 'object_recognition'
        % Load subject-level RSA data
        load(fullfile(home_dir, 'results', proj, subject, [subject, '_obj_rsa.mat']), 'rsa')
        
        % Load group-level RSA data
        load(fullfile(home_dir, 'results', proj, 'rsa_obj_group.mat'), 'rsa_group')
        
        % Add subject data to group-level data
        sub_position = length(rsa_group.sub_id) + 1;
        rsa_group.same(:, :, sub_position) = mean(rsa.same, 3);
        for lag = 1:20
            diff_temp = rsa_group.diff{lag};
            diff_temp(:, :, sub_position) = mean(rsa.diff{lag}, 3);
            rsa_group.diff{lag} = diff_temp;
        end
        rsa_group.label.same{sub_position} = rsa.label.same;
        rsa_group.label.diff{sub_position} = rsa.label.diff;
        rsa_group.sub_id(sub_position) = sub_id;
        
        % Save group-level RSA data
        save_dir = fullfile(home_dir, 'results', proj, 'rsa_obj_group.mat');
        save(save_dir, 'rsa_group')
    
    case 'sequence_memory'
        % Load subject-level RSA data
        load(fullfile(home_dir, 'results', proj, subject, [subject, '_seq_rsa.mat']), 'rsa')
        
        % Load group-level RSA data
        load(fullfile(home_dir, 'results', proj, 'rsa_seq_group.mat'), 'rsa_group')
        
        % Add subject data to group-level data
        sub_position = length(rsa_group.sub_id) + 1;
        rsa_group.same(:, :, sub_position) = mean(rsa.same, 3);
        rsa_group.label{sub_position} = rsa.label;
        rsa_group.sub_id(sub_position) = sub_id;
        
        % Save group-level RSA data
        save_dir = fullfile(home_dir, 'results', proj, 'rsa_seq_group.mat');
        save(save_dir, 'rsa_group')

    case 'obj2seq'
        % Load subject-level RSA data
        load(fullfile(home_dir, 'results', proj, subject, [subject, '_obj2seq_rsa.mat']), 'rsa')
        
        % Load group-level RSA data
        load(fullfile(home_dir, 'results', proj, 'rsa_obj2seq_group.mat'), 'rsa_group')
        
        % Add subject data to group-level data
        sub_position = length(rsa_group.sub_id) + 1;
        rsa_group.same(:, :, sub_position) = mean(rsa.same, 3);
        rsa_group.diff(:, :, sub_position) = mean(rsa.diff, 3);
        rsa_group.label.same{sub_position} = rsa.label.same;
        rsa_group.label.diff{sub_position} = rsa.label.diff;
        rsa_group.trials{sub_position} = size(rsa.same, 3);
        rsa_group.sub_id(sub_position) = sub_id;
        
        % Save group-level RSA data
        save_dir = fullfile(home_dir, 'results', proj, 'rsa_obj2seq_group.mat');
        save(save_dir, 'rsa_group')
        
end
end
