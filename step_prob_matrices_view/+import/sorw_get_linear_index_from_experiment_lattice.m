function r_latt = sorw_get_linear_index_from_experiment_lattice(L,r_experiment_lattice)
    % L -> [ W, H ]
    % r_experiment_lattice -> [x,y]
    r_experiment_lattice = double(r_experiment_lattice)+1;% we add one because in python, the lattice coord system starts in 0,0; here it starts in 1,1
    r_latt               = sub2ind(L,r_experiment_lattice(2),r_experiment_lattice(1)); % we change column and row
end