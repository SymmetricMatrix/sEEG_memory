function mean_value = caculate_mask_mean(data, mask)
% CACULATE_MASK_MEAN Calculate the mean value in the mask for repeat measurements
%   Input:
%       data: 3D array, the first 2D is the data and the 3rd is different measurements
%       mask: 2D binary mask
%
%   Example:
%       mean_value = caculate_mask_mean(data, mask);
%
%   See also: mean

mean_value = nan(1,size(data,3));
for i =1:size(data,3)
    % Apply the mask to the data
    masked_data = data(:,:,i) .* mask;
    % Calculate the mean value in the mask for repeat measurements
    mean_value(i) = mean(masked_data(:),'omitnan');
end
end