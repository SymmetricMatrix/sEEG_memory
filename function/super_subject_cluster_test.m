function [x_zscored, h0_zscore, zmapthresh] = super_subject_cluster_test( ...
    x_obs, null_dist, z_threshold, mcc_pval, tail, do_zscore, varargin)

% This function performs a cluster based permutation test on a single observation array with respect to a null
% distribution. Correction is based on cluster size.


% inputs:
% x_obs: (1 or 2D array) contains the observed data for which to compute the cluster based permutation test
% null_dist: (2 or 3D array) n x p x (q) matrix containing the null distribution associated with the observed data. 
%                  n: the number of permuatations, p and (q): the dimensions of the observed data
%                  (time and frequency, or only time, or time x time...)
% z_threshold: (float) z score threshold for the significant cluster.
% mcc_pval: p-value for cluster based correction 
% tail: (int) 1 for upper tail, -1 lower tail, 0 two tailed
% do_zscore: (boolean) if the data are zscores already, don't redo the z transform 
% 
% outputs:
% x_zscored: observed values z scored
% h0_zscore: null distribution values z scored
% zmapthresh: cluster-coorected zmap of the observed value

% default values
p = inputParser;
addParameter(p,'mkplt', false ,@islogical)
addParameter(p,'time',[],@isnumeric)

parse(p,varargin{:})
mkplt = p.Results.mkplt;
time = p.Results.time;


% Checking the dimensions of the two input matrices:
if ~isequal(ndims(x_obs), ndims(null_dist))
    error('The dimension of the observed matrix and null distribution are inconsistent!');
end

% Get the original shape:
sample_shape = size(x_obs);
% Get the number of tests:
n_tests = prod(sample_shape);

% if ~isequal(size(exclude), sample_shape) && exclude ~= []
%     error('exclude must be the same shape as X[0]');
% end

% Step 1: Calculate z score for original data
% -------------------------------------------------------------
if do_zscore
    disp('Z scoring the data by null distribution statistics...');
    sigma = std(null_dist,[],2);
    mu = mean(null_dist, 2);

    x_zscored = (x_obs - mu) ./ sigma;

    h0_zscore = zscore(null_dist, [], 2);

else
    x_zscored = x_obs;
    h0_zscore = null_dist;
end



% Step 2: Cluster the observed data:
% -------------------------------------------------------------
disp('Finding the cluster in the observed data...');
%[clusters, cluster_stats] = find_clusters(x_zscored, z_threshold, tail, adjacency, max_step, include, [], t_power, true);

if tail == 0 % two-tailed
    zmapthresh = [x_zscored < -z_threshold | x_zscored > z_threshold];
elseif tail == 1 % upper tail
    zmapthresh = [x_zscored > z_threshold];
else % lower tail
    zmapthresh = [x_zscored < z_threshold];
end

% get number of elements in largest supra-threshold cluster
cluster_info = bwconncomp(zmapthresh);
clusters = cellfun(@numel,cluster_info.PixelIdxList); 



if isempty(clusters)
    warning('No clusters found in observed data.')

else

    % Step 3: Compute the clusters for the null distribution:
    % -------------------------------------------------------------

    n_permutes = size(null_dist, ndims(null_dist));
    max_clust_info  = zeros(n_permutes,1);


    for permi = 1:n_permutes % loop over permutations
        if ndims(null_dist) == 2 % 2d (i.e., time-resolved)
            this_perm = h0_zscore(:,permi);
        else    % 3d (i.e., time-frequency, timextime)
            this_perm = h0_zscore(:,:,permi);
        end

        if tail == 0 % two-tailed
            h0_ins = [this_perm < -z_threshold | this_perm > z_threshold];
        elseif tail == 1 % upper tail
            h0_ins = [this_perm > z_threshold];
        else % lower tail
            h0_ins = [this_perm < z_threshold];
        end

        % get number of elements in largest supra-threshold cluster
        cluster0_info = bwconncomp(h0_ins);
        max_clust_info(permi) = max([ 0 cellfun(@numel,cluster0_info.PixelIdxList) ]); % notes: cellfun is superfast, and the zero accounts for empty maps

    end

    % Step 4: Remove the clusters smaller than cluster size threshold
    % -------------------------------------------------------------

    clust_threshold = prctile(max_clust_info,100-mcc_pval*100);

    % identify clusters to remove
    whichclusters2remove = find(clusters<clust_threshold);

    % remove clusters
    for i=1:length(whichclusters2remove)
        zmapthresh(cluster_info.PixelIdxList{whichclusters2remove(i)})=0;
    end

end

% if mkplt
%     plot(time, x_obs, 'k', 'LineWidth',1 )
%     hold on
%     yline(0.5, 'k--')
%     xlabel('Time from the syllable onset (s)')
%     ylabel('AUC')
%     yvals = get(gca,'ylim');
%     plot(time(zmapthresh), repmat(yvals(1), sum(zmapthresh),1) ,'r', 'LineWidth',2 )
%     xlim([-0.1 0.5])
% end