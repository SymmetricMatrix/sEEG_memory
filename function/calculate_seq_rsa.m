function [seq_r,seq_p] = calculate_seq_rsa(data)
% Calculates the correlation between 18 pictures for each sequence set in
% sequence task
% Inputs:
% - data: sequence_sw 4D-data, channel*frex*time*trials
% Outputs:
% - pic_corr: 4D-data, 18*18*750*12


t = size(data, 3);
seq_set  = size(data, 4)/18;
seq_r = nan(18,18,t,seq_set);
seq_p= nan(18,18,t,seq_set);
tic
for seqi=1:seq_set
    for timei = 1:t
        for pici2 = 1:18
            for pici1 = pici2+1:18
                rr1 = reshape(data(:,:,timei,pici1+(seqi-1)*18), [],1);
                rr2 = reshape(data(:,:,timei,pici2+(seqi-1)*18), [],1);
                [r,p]= corr(rr1, rr2, 'type', 'spearman');
                seq_r(pici1,pici2,timei,seqi) =  r;
                seq_p(pici1,pici2,timei,seqi) =  p;
            end
        end
    end
end
toc

% Modify correlation values trans to Fisher Z using the atanh function
seq_r = atanh(seq_r);

end