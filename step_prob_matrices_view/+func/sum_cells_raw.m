function s = sum_cells_raw(C)
    n = numel(C);
    s = C{1};
    for i = 2:n
        s = s + C{i};
    end
end