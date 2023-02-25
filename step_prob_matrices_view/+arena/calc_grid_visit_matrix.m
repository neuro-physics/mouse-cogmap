function G = calc_grid_visit_matrix(sites)
    L = round(sqrt(numel(sites)));
    G = reshape([sites(:).x],[L,L]);
end