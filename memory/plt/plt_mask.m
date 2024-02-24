function plt_mask(data_size, cp, pp, i)
% PLT_MASK Plot the cluster after permutation
%   Input:
%       data_size: data size
%       cp: cluster id
%       pp: cluster p value
%       i: The ith cluster
%
%   Example:
%       plt_mask([100, 100], cp, pp, 1);


mask = zeros(data_size);
mask(cp{1, i}) = 1;
imagesc(mask)
title(['p=',num2str(pp(i))])
end