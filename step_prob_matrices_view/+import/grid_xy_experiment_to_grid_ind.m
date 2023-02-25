function r = grid_xy_experiment_to_grid_ind(L,r)
    r = double(sub2ind(L,r(:,2)+1,r(:,1)+1));
end