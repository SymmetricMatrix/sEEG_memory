function pic_corr = calculate_rsa(data1, data2, pic_pair)
% Calculates the correlation between two sets of data, data1 and data2, at specific time points specified by pic_pair.
% Inputs:
% - data1: 4D-data, channel*frex*time*trials
% - data2: 4D-data, channel*frex*time*trials
% - pic_pair: 2D-data, [data1_pic data2_pic]
% Outputs:
% - pic_corr: 3D-data, time*time*pair

data1_t = size(data1, 3);
data2_t = size(data2, 3);
rsa_data2 = size(data1, 1) * size(data1, 2); % rsa data2 length = channel*frex 
pic_corr = zeros(data1_t, data2_t, size(pic_pair, 1)); % time*time*pair

for j = 1:size(pic_pair, 1) % paired
    rr1 = zeros(rsa_data2, data1_t);
    rr2 = zeros(rsa_data2, data2_t);
    for i = 1:data1_t % time point
        r1 = reshape(data1(:, :, i, pic_pair(j, 1)), rsa_data2, 1);
        rr1(:, i) = r1;
    end
    for i = 1:data2_t % time point
        r2 = reshape(data2(:, :, i, pic_pair(j, 2)), rsa_data2, 1);
        rr2(:, i) = r2;
    end
    pic_corr(:, :, j) = corr(rr1, rr2, 'type', 'spearman');
end

% Modify correlation values using the atanh function
pic_corr = atanh(pic_corr);
end
