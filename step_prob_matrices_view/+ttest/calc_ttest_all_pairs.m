function T = calc_ttest_all_pairs(data_cell,varargin)
% performs T-test between all pairs of cells in data_cell
    N = numel(data_cell);
    T = repmat(ttest.ttest2Struct(),N,N);
    for i = 1:N
        for j = (i+1):N
            T(i,j) = ttest.ttest2Struct(data_cell{i},data_cell{j},varargin{:});
        end
    end
    T  = struct_mat_to_struct_of_matrices(rmfield(rmfield(T,'confInt'),'stats'));
    

end

function S = struct_mat_to_struct_of_matrices(T)
    sz = size(T);
    A = struct2table(T(:));
    is_empty = arrayfun(@(x)isempty(x{1}),A.h);
    A(is_empty,:) = repmat({{NaN}},numel(find(is_empty)),size(A,2));
    S = table2struct(A,'ToScalar',true);
    fn = fieldnames(S);
    for i = 1:numel(fn)
        S.(fn{i}) = cellfun(@double,S.(fn{i}));
        S.(fn{i}) = reshape(S.(fn{i}),sz);
    end
end