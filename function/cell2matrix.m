function [matrix,idx] = cell2matrix(cell_array,dim)
% turn cell array to matrix, each element in cell is same size
% input: cell array (N * 1), and some cell is empty
%        dim, dim = 1 add a dimension
% output: matrix:  matrix format data
%         ind:     the index of not empty cell
if (nargin < 2)
        dim = 1;
end
    
num_cells = length(cell_array);
matrix=[];
idx = [];
for i = 1:num_cells
    if ~isempty(cell_array{i}) &&  ~all(isnan(cell_array{i}(:)))
        dims = ndims(cell_array{i});
        if dim == 0
            matrix = cat(dims, matrix, cell_array{i});
        elseif dim==1
            matrix = cat(dims+1, matrix, cell_array{i});
        end
        idx = [idx,i];
    end
end

end