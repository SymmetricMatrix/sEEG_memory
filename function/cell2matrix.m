function [matrix,idx] = cell2matrix(cell_array)
% turn cell array to matrix, each element in cell is same size
% input: cell array (N * 1), and some cell is empty
% output: matrix:  matrix format data
%         ind:     the index of not empty cell

num_cells = length(cell_array);
dims = ndims(cell_array{1});
matrix=[];
idx = [];
for i = 1:num_cells
    if ~isempty(cell_array{i})
        matrix = cat(dims+1, matrix, cell_array{i});
        idx = [idx,i];
    end
end

end