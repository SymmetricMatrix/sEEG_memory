function [pic_idx,pic_labels,pic_label_all] = pic_pair_object(subject,type,lag,flag)
% Returns a sorted list of picture labels and their positions for a given subject ID.
% The picture labels are extracted from the "object.csv" file using regular expressions.
% The "object.csv" file must be located at '/bigvault/Projects/seeg_pointing/gather/Tabel/object.csv'.

% Input:
%   subject - A string representing the subject ID, such as 'subject1'.
%   type - A string representing the type of picture pairs to return. Can be either 'same' or 'diff'.
%   lag - An integer representing the time lag between the two pictures in a pair. Default is 1.
%   flag - An integer representing the flag for selecting the picture pairs. Default is 12.

% Output:
%   pic_idx - A matrix with two columns representing the first present picture
%             location and second present picture location.
%   pic_labels - A matrix with two columns representing the picture label and its position.
%             The list is sorted in ascending order by picture label.
%   pic_label_all - A matrix with two columns representing the picture label and its position.
%             All images label and location.

% Dependent data:
%   The function reads the "object.csv" file located at '/bigvault/Projects/seeg_pointing/gather/Tabel/object.csv'.

if (nargin<4)
    flag=12;
end

% Read the "object.csv" file and extract the picture codes for the given subject ID using regular expressions.
sub_id = regexp(subject, '\d*', 'match');
object = readtable('/bigvault/Projects/seeg_pointing/gather/Tabel/object.csv', 'VariableNamingRule', 'preserve');
pic_codes = object(object.sub_id == str2double(sub_id{1}), {'Code'});
pic_codes = pic_codes.Code(2:3:end);
pic_labels = [];
exp = '([0-9]*).PNG';
for i = 1:size(pic_codes, 1)
    ppic = regexp(pic_codes{i}, exp, 'tokens');
    if ~isempty(ppic)
        pic_labels = [pic_labels; str2double(ppic{1, 1}{1})];
    end
end

% All images label and location
[pic_label_all(:, 1), pic_label_all(:, 2)] = sort(pic_labels(:, 1));

%% get pic label form origin file
% pic_dir=dir(fullfile([home_dir,'subject/',subject,'/beh/',proj],'*run-obj*.log'));
% filename=[pic_dir.folder,'/',pic_dir.name];
% log=readmatrix(filename, 'OutputType', 'string', "Delimiter",'	');
% pic_label=[];
% exp='([0-9]*).PNG';
% for i=1:size(log,1)
%     ppic=regexp(log(i,4),exp,'tokens');
%     if ~isempty(ppic)
%         pic_label=[pic_label;ppic{1}];
%     end
% end
% pic_label=double(pic_label(1:2:end,:));

%% Select two object rounds for specific subjects.
num_pics_per_round = size(pic_labels, 1) / 3;
switch subject
    case {'subject1', 'subject2', 'subject4'}
        if flag == 12
            pic_labels = pic_labels(1:2*num_pics_per_round, :);
        elseif flag == 23
            pic_labels = pic_labels([1:num_pics_per_round, end-num_pics_per_round+1:end], :);
        else
            pic_labels = pic_labels(num_pics_per_round+1:end, :);
        end
    case {'subject8', 'subject9', 'subject10','subject11', 'subject13'}
        disp('Only did a round of object experiments. No pictures pair')
        pic_idx = [];
        pic_labels = [];
        return
end

% Sort the picture labels in ascending order.
[pic_labels(:, 1), pic_labels(:, 2)] = sort(pic_labels(:, 1));
pic_same_idx=[pic_labels(1:2:end,2),pic_labels(2:2:end,2)];

%% find same pic index and diff pic index
pic_idx=[];
switch type
    case 'same'
        pic_idx=pic_same_idx;
        
    case 'diff'
        %% find diff pic index
        pic1_idx = pic_same_idx(:,1);
        pic2_idx = pic_same_idx(:,2);
        pics = size(pic_same_idx,1);
        
        % Calculate the indices after lag
        pic_diff_idx = pic_same_idx + lag;
        
        % 1. Check if indices are out of bounds  (prepare)
        % 1.1 Calculate the distance between all pairs of indices
        pic_all_dist = zeros(pics);
        for i = 1:length(pic1_idx)
            for j = 1:length(pic2_idx)
                pic_all_dist(i,j) = pic2_idx(j) - pic1_idx(i);
            end
        end
        % 1.2 Calculate the indices of the pairs of images with the same distance as the original pairs
        pic_diff_sd = zeros(length(pic1_idx),2); % different pics with same distance with same pics
        pic_dist1 = pic_all_dist - diag(diag(pic_all_dist));
        for i = 1:pics
            pic_dif_idx = find(pic_dist1 == pic_all_dist(i,i));
            [m,n] = ind2sub(size(pic_dist1),pic_dif_idx(ceil(length(pic_dif_idx)/2))); % save the number in the middle
            pic_diff_sd(i,:) = [pic1_idx(m),pic2_idx(n)]; % save idx
        end
        
        % 2. Check if the indices after lag are still within the same set of pictures (replace)
        % 2.1 Find the indices of the pairs of images that are out of bounds
        diff_change_idx = [find(pic_diff_idx(:,1) > max(pic_same_idx(:,1)))', ...
            find(pic_diff_idx(:,2) > max(pic_same_idx(:,2)))', ...
            find_same_idx(pic_same_idx,pic_diff_idx)];
        diff_change_idx = unique(diff_change_idx);
        % 2.2 Replace the out of bounds indices with the indices of the pairs with the same distance as the original pairs
        pic_diff_idx(diff_change_idx,:) = pic_diff_sd(diff_change_idx,:);
        
        pic_idx = pic_diff_idx;
end
end