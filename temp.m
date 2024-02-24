clc
clear
%% general parameter
%proj = 'object_recognition';% object_recognition  sequence_memory
%run('/bigvault/Projects/seeg_pointing/0_code/function/sEEG_initialize.m')
% get subjects
ele_excl=readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/label.csv');
home_dir = '/bigvault/Projects/seeg_pointing/';
%%
projs = {'seq_pic_total','seq_pre_after'};
for i = 1:length(projs)
    proj = projs{i};
    disp(proj)
    freq = 1:46;
    for sub_id = 1:27
        try
            subject = ['subject', num2str(sub_id)];
            read_dir = fullfile(home_dir, 'results', proj, subject, '/');
            save_dir = fullfile(home_dir, 'results', proj, subject, '/');
            mkdir(save_dir);
            switch proj
                case 'object_recognition'
                    data1 = load_mat(fullfile(home_dir, 'results/object_recognition', subject, [subject, '_sw.mat']));
                    data2 = data1;
                case {'seq_pic_total', 'seq_pre_after'}
                    data1 = load_mat(fullfile(home_dir, 'results/sequence_memory', subject, [subject, '_sw.mat']));
                    data2 = data1;
                    save_dir = fullfile(home_dir,'results','sequence_memory',subject,'/');
                case 'obj2seq'
                    data1 = load_mat(fullfile(home_dir, 'results/object_recognition', subject, [subject, '_sw.mat']));
                    data2 = load_mat(fullfile(home_dir, 'results/sequence_memory', subject, [subject, '_sw.mat']));
            end
            disp(subject);
            seeg_rsa(data1, data2, subject, proj, freq, save_dir);
        catch ME
            % display the error message
            disp([num2str(sub_id), '----------error-------']);
            disp(ME.message);
            % skip the current loop
            continue;
        end
    end
end