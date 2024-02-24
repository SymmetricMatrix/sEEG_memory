function seeg_rsa(data1,data2,subject, proj, freq, save_dir)
% Calculate RSA for object recognition or object2sequence
% Inputs:
%   subject: subject ID
%   proj: project name ('object_recognition' or 'sequence_memory' or 'obj2seq')
%   freq: frequency range to use (default: [1:46])
%   save_dir: the save directory path (default: '/bigvault/Projects/seeg_pointing/results/proj/subject1/')
%
% Outputs:
%   rsa: structure containing RSA results
%        object: rsa = struct('same', [], 'diff', [], 'label', []);
%        sequence_memory: seq_pic_total,seq_pre_after, 'isnr', [],'label'
%        obj2seq: rsa = struct('same', [], 'diff', [], 'label', 'round', []);

%% Parameter setting

% Determine where the picture appears
obj_pic = 51:165; % original [-2,3], save [-0.5,1.5], pic [0,1.15]
seq_pic = 251:500;% original [-5,7], save [-2.5,5], pic [0,2.5]
seq_pre = 1:200;  % original [-5,7], save [-2.5,5], pre interval [-2.5,-0.5]
seq_after = 501:700;% original [-5,7], save [-2.5,5], pre interval [2.5,4.5]
%% caculate rsa
% Load object data_sw, channnel*frex*time*trials
switch proj
    case 'object_recognition'
        % initialize rsa
        rsa = struct('same', [], 'diff', [], 'label', []);
        
        % Pic_same RSA
        pic_match_same = pic_pair_object(subject, 'same');
        rsa.same = calculate_rsa(data1(:, freq, :, pic_match_same(:,1)), data2(:, freq, :, pic_match_same(:,2)));
        rsa.label.same = pic_match_same;
        
        % Pic_diff RSA
        for lag = 1:20
            pic_match_diff = pic_pair_object(subject, 'diff', lag);
            rsa.diff{lag} = calculate_rsa(data1(:, freq, :, pic_match_diff(:,1)), data2(:, freq, :, pic_match_diff(:,2)));
            rsa.label.diff{lag} = pic_match_diff;
        end
        
        save(fullfile(save_dir, [subject, '_obj_rsa.mat']), 'rsa', '-v7.3');
    case 'sequence_memory'
        % initialize rsa
        rsa = struct('pic_total', [],'pre_after',[], 'isnr', [],'label', []);
        
        % pic_total and pre_after RSA
        code = event_code(str2num(subject(8:end)));
        seq_code = find(code>0);
        pic_match_same= [seq_code,seq_code];
        rsa.pic_total = calculate_rsa(data1(:, freq, seq_pic, pic_match_same(:,1)), data2(:, freq, :, pic_match_same(:,2)));
        rsa.pre_after = calculate_rsa(data1(:, freq, seq_pre, pic_match_same(:,1)), data2(:, freq,  seq_after, pic_match_same(:,2)));
        rsa.label.same = pic_match_same;
        
        % isnr, Improve signal noise to ratio
        bd_idx = [7,13,25,31,43,49];
        seq_code1 = [1:12,19:30,37:48]';
        seq_code2 = reshape(repmat(bd_idx, 6, 1),[],1);
        bd_code = [seq_code1, seq_code2;seq_code1+18*6, seq_code2+18*6];
        non_bd_code = [seq_code1+18*3, seq_code2+18*3;seq_code1+18*9, seq_code2+18*9];
        rsa.isnr.boundary = calculate_rsa(data1(:, freq, seq_after, bd_code(:,1)), data2(:, freq,  seq_after, bd_code(:,2)));
        rsa.isnr.non_boundary = calculate_rsa(data1(:, freq, seq_after, non_bd_code(:,1)), data2(:, freq,  seq_after, non_bd_code(:,2)));
        rsa.label.isnr.boundary = bd_code;
        rsa.label.isnr.non_boundary = non_bd_code; 
        
        save(fullfile(save_dir, [subject,'_seq_rsa.mat']), 'rsa', '-v7.3');
        
    case 'obj2seq'
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
            rsa.round.same{i} = calculate_rsa(data1(:, freq, :, same_pic_idx(:,1)), data2(:, freq, :, same_pic_idx(:,2)));
            rsa.round.diff{i} = calculate_rsa(data1(:, freq, :, diff_pic_idx(:,1)), data2(:, freq, :, diff_pic_idx(:,2)));
        end
        
        % Save label info
        rsa.label.same = pic_match_same;
        rsa.label.diff = pic_match_diff;
        
        % Mean object round: time*time*trials
        rsa.same = mean(cat(4, rsa.round.same{:}), 4);
        rsa.diff = mean(cat(4, rsa.round.diff{:}), 4);
        mkdir(save_dir)
        save(fullfile(save_dir, [subject, '_obj2seq_rsa.mat']), 'rsa', '-v7.3');
        
    otherwise
        error('proj input is wrong')
end
end
