function pic_corr = rsa(data, pic_pair)
% This function calculates the Representation similarity analysis between two sets of data
% and applies the inverse hyperbolic tangent function to the correlation matrix.
%
% Inputs:
%   data: 4D-data, channel*frex*time*trials
%   pic_pair: 2D-data, [first_pic second_pic]
%
% Outputs:
%   pic_corr: time*time*pair

% Get the number of time points and the length of the RSA sequence
num_time_points = size(data, 3);
rsa_seq_length = size(data, 1) * size(data, 2);

% Initialize the pic_corr matrix
num_pic_pairs = size(pic_pair, 1);
pic_corr = zeros(num_time_points, num_time_points, num_pic_pairs);

% Calculate the Spearman correlation for each pic_pair
for j = 1:num_pic_pairs
    % Initialize the rr1 and rr2 matrices
    rr1 = zeros(rsa_seq_length, num_time_points);
    rr2 = zeros(rsa_seq_length, num_time_points);
    
    % Reshape the data for each time point and pic_pair
    for i = 1:num_time_points
        r1 = reshape(data(:, :, i, pic_pair(j, 1)), rsa_seq_length, 1);
        r2 = reshape(data(:, :, i, pic_pair(j, 2)), rsa_seq_length, 1);
        rr1(:, i) = r1;
        rr2(:, i) = r2;
    end
    
    % Calculate the Spearman correlation and store it in the pic_corr matrix
    pic_corr(:, :, j) = corr(rr1, rr2, 'type', 'spearman');
end

% Apply the inverse hyperbolic tangent function to the correlation matrix
pic_corr = atanh(pic_corr);
end