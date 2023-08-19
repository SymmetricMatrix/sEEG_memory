function idx=find_same_idx(A,B)
% Find the same rows as B and A,reyurn the idx of B
idx=[];
for i=1:size(B,1)
    for j=1:size(A,1)
        if A(i,:)==B(j,:)
            idx=[idx,i];
        end
    end
end
end