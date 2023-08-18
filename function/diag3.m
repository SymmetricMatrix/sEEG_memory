function diag_3 = diag3(matrix)
% Extract the diagonal elements of the current 2D matrix using the diag function
% and store them in the corresponding column of diag_3.

for i = 1 : size(matrix,3)
    diag_3(:,i) = diag(matrix(:,:,i));
end

end