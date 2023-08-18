function seeg_rsa(subject, proj, freq, home_dir,save_dir)
% Calculate RSA for object recognition or object2sequence
% Inputs:
%   subject: subject ID
%   proj: project name ('object_recognition' or 'sequence_memory' or 'obj2seq')
%   freq: frequency range to use (default: [1:46])
%   home_dir: home directory path (default: '/bigvault/Projects/seeg_pointing/')
% Outputs:
%   rsa: structure containing RSA results
%        object: rsa = struct('same', [], 'diff', [], 'label', []);
%        sequence: rsa = struct('same', [], 'label', []); % self rsa
%        obj2seq: rsa = struct('same', [], 'diff', [], 'label', 'round', []);
%% Parameter setting
% Set default values for freq and home_dir if they are not provided
if (nargin<3)
    freq = 1:46;
end

if (nargin<4)
    home_dir = '/bigvault/Projects/seeg_pointing/';
    % save dir
    save_dir = fullfile(home_dir, 'results', proj);
end

% Determine where the picture appears
obj_pic = 51:165; % original [-2,3], save [-0.5,1.5], pic [0,1.15]
seq_pic = 251:500;% original [-5,7], save [-2.5,5], pic [0,2.5]



%% caculate rsa
% Load object data_sw, channnel*frex*time*trials


switch proj
    case 'object_recognition'
        % load data
        sw_file = fullfile(home_dir, 'results/object_recognition', subject, [subject, '_sw.mat']);
        load(sw_file, 'data_sw');
        
        % initialize rsa
        rsa = struct('same', [], 'diff', [], 'label', []);

        % Pic_same RSA
        pic_match_same = pic_pair_object(subject, 'same');
        rsa.same = calculate_rsa(data_sw(:, freq, :, :), data_sw(:, freq, :, :), pic_match_same);
        rsa.label.same = pic_match_same;
        
        % Pic_diff RSA
        for lag = 1:20
            pic_match_diff = pic_pair_object(subject, 'diff', lag);
            rsa.diff{lag} = calculate_rsa(data_sw(:, freq, :, :), data_sw(:, freq, :, :), pic_match_diff);
            rsa.label.diff{lag} = pic_match_diff;
        end
        
        save(fullfile(save_dir, subject, [subject, '_obj_rsa.mat']), 'rsa', '-v7.3'); 
    case 'sequence_memory'
        % Load sequence_sw, channnel*frex*time*trials
        sw_file = fullfile(home_dir, 'results/sequence_memory', subject, [subject, '_sw.mat']);%%%%
        load(sw_file, 'data_sw');%%%%%
%         data_sw = load(sw_file);
%         data_sw = data_sw.sequence_sw;
        
        % initialize rsa
        rsa = struct('same', [], 'label', []);

        % Pic_same RSA
        code = event_code(str2num(subject(8:end)));
        seq_code = find(code>0);
        pic_match_same= [seq_code,seq_code];
        rsa.same = calculate_rsa(data_sw(:, freq, seq_pic, :), data_sw(:, freq, :, :), pic_match_same);
        rsa.label.same = pic_match_same;
        
        save(fullfile(save_dir, [subject, '_sequence_rsa.mat']), 'rsa', '-v7.3');

    case 'obj2seq'
        % Load sequence_sw, channnel*frex*time*trials
        sw_file = fullfile(home_dir, 'results/object_recognition', subject, [subject, '_sw.mat']);
        load(sw_file, 'data_sw');
        sw_file = fullfile(home_dir, 'results/sequence_memory', subject, [subject, '_sw.mat']);
        sequence_sw = load(sw_file);
        sequence_sw = sequence_sw.data_sw;
        
        % initialize rsa
        rsa = struct('same', [], 'diff', [], 'label', [], 'round', []);
        
        pic_match_same = pic_pair_obj2seq(subject, 'same');
        pic_match_diff = pic_pair_obj2seq(subject, 'diff');
        obj_round = size(pic_match_same, 2) - 3;
        
        rsa.round = struct('same', [], 'diff', []);
        for i = 1:obj_round
            same_pic_idx = [pic_match_same(:, i+1), pic_match_same(:, end)];
            diff_pic_idx = [pic_match_diff(:, i+1), pic_match_diff(:, end)];
            
            % RSA: time*time*trials
            rsa.round.same{i} = calculate_rsa(data_sw(:, freq, :, :), sequence_sw(:, freq, :, :), same_pic_idx);
            rsa.round.diff{i} = calculate_rsa(data_sw(:, freq, :, :), sequence_sw(:, freq, :, :), diff_pic_idx);
        end
        
        % Save label info
        rsa.label.same = pic_match_same(:, 2:obj_round+1);
        rsa.label.diff = pic_match_same(:, end);
           
        % Mean object round: time*time*trials
        rsa.same = mean(cat(4, rsa.round.same{:}), 4);
        rsa.diff = mean(cat(4, rsa.round.diff{:}), 4);
        
        save_dir = fullfile(save_dir, subject);
        mkdir(save_dir)
        save(fullfile(save_dir, [subject, '_obj2seq_rsa.mat']), 'rsa', '-v7.3');
        
    otherwise
        error('proj input is wrong')
end
end
