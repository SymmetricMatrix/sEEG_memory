function [matrix,idx] = cellmerge(cell_array,dim)
% turn cell array to matrix, each element in cell is same size
% input: cell array (N * M), and some cell is empty
%        dim, dim mean merge to this dim
% output: matrix:  matrix format data
%         ind:     the index of not empty cell
if (nargin < 2)
        dim = 2;
end
    
num_cells = size(cell_array,-dim+3);
matrix=[];
idx = [];
for i = 1:num_cells
    if dim == 1
        [matrix{i},idx{i}] = cell2matrix(cell_array(:,i));
        
    elseif dim==2
        [matrix{i},idx{i}] = cell2matrix(cell_array(i,:));
    end
end
end