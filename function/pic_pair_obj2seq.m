function pic_match = pic_pair_obj2seq(subject, type)
% Returns a sorted list of picture labels and their positions for a given subject ID between object and sequence.
% It takes a few minutes to load the wavelet file
%
% Inputs:
%   subject - A string representing the subject ID, such as 'subject1'.
%   type - A string representing the type of picture pair, either 'same' or 'diff'.
%
% Output:
%   pic_match - A matrix containing the picture labels and their positions in the format [pic_label, obj_loc1, obj_loc2, ..., pic_label, seq_loc].

if (nargin<3)
    home_dir='/bigvault/Projects/seeg_pointing/';
    proj='sequence_memory';
end

% Load the trl data from the wavelet file
load(fullfile(home_dir, 'results', proj, subject, [subject, '_cfg.mat']))
trl = cfg.trl;

% Extract the sequence and object picture labels and positions
seq_test = sum(trl(:,5)==0);
seq_pic = find(trl(:,5)~=0);
seq_pic =[seq_pic-seq_test,seq_pic];
seq_pic =seq_pic(seq_pic(:,1)<217,:);% exclude over 2 round
% seq_boundary_pic = find(trl(:,5)~=0 & trl(:,4)<30);
% seq_non_boundary_pic = find(trl(:,5)~=0 & trl(:,4)>30);
% seq_boundary_pic = [seq_boundary_pic-seq_test,seq_boundary_pic];
% seq_non_boundary_pic = [seq_non_boundary_pic-seq_test,seq_non_boundary_pic];
seq_boundary_pic = seq_pic([1:18*3,18*6+1:18*9],:);
seq_non_boundary_pic = seq_pic([18*3+1:18*6,18*9+1:18*12],:);
%%  object label
[~,~,pic_sort]=pic_pair_object(subject,'same');
obj_round = size(find(pic_sort(:,1)==pic_sort(1,1)),1);

obj_label = unique(pic_sort(:,1));
obj_pic=obj_label;
for pic=1:size(obj_label,1)
    % find location of pic
    obj_pic(pic,2:obj_round+1) = pic_sort(find(pic_sort(:,1)==obj_label(pic)),2)';
end

% merge object and sequence
[~,idx_obj,idx_seq] = intersect(obj_pic(:,1),seq_pic(:,1));
same_pic = [obj_pic(idx_obj,:),seq_pic(idx_seq,:)];% pic_label,obj_loc1,obj_loc2...,pic_label,seq_loc

% object-sequence match
switch type
    case 'same'
        pic_match = same_pic ;
    case 'diff'
        % difference
        diff_pic = same_pic;
        diff_pic(:,end-1:end)=0;
% rand rule old 
%         rng(123);           % sets the seed to 123
%         for k = 1:size(diff_pic,1)
%             seq_idx = diff_pic(k,1);
%             if ismember(seq_idx,seq_boundary_pic)
%                 rand_nb = randi([1, size(seq_non_boundary_pic,1)]);
%                 diff_pic(k,end-1:end)=seq_non_boundary_pic(rand_nb,:);
%             else
%                 rand_b = randi([1, size(seq_boundary_pic,1)]);
%                 diff_pic(k,end-1:end)=seq_boundary_pic(rand_b,:);
%             end
%         end
        rng(123);
        n = length(seq_non_boundary_pic);
        idx = randperm(n);
        rand_seq_non_boundary_pic = seq_non_boundary_pic(idx,:);
        rand_seq_idx1 = [seq_boundary_pic,rand_seq_non_boundary_pic];
        rand_seq_idx2 = [rand_seq_non_boundary_pic,seq_boundary_pic];
        rand_seq_idx = [rand_seq_idx1;rand_seq_idx2];
        
        for k = 1:size(diff_pic,1)
            seq_idx = diff_pic(k,1);
            diff_pic(k,end-1:end)=rand_seq_idx(rand_seq_idx(:,1)==seq_idx,3:4);
        end
        pic_match = diff_pic ;
end

end
