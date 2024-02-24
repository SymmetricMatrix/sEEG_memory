function [H,P,T]=ttest_2d(data1,data2)
% caculate ttest(paired) for 2D data
% Input: data1, 3D
%        data2 3D
% Output: H, H=0 indicates that the null hypothesis cannot be rejected at the 5% significance level.  
%         P, p-value
%         T, T-value

H = [];
P = [];
T = [];
for i=1:size(data1,1)
    for j=1:size(data1,2)
        [H(i,j),P(i,j),~,STATS] =ttest(squeeze(data1(i,j,:)),squeeze(data2(i,j,:)));
        T(i,j)=STATS.tstat;
    end
end
end