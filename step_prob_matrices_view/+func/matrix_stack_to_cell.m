function A_cell = matrix_stack_to_cell(A)
    A_cell = cell(1,size(A,3));
    for k = 1:numel(A_cell)
        A_cell{k} =  squeeze(A(:,:,k));
    end
end