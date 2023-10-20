function A = stack_matrices(A_cell)
    A = A_cell{1};
    for k = 2:numel(A_cell)
        A(:,:,end+1) = A_cell{k};
    end
end