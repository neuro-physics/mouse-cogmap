function p = sorw_GetSimulationParamFromExperiments(L_lattice,r_target,stop_at_food)
% L_lattice -> size (width or height) of the lattice
% r_target -> [x,y] coords (indices) of the target in the lattice (0-based, it came from python)
% stop_at_food -> true if the experiment stopped at the first encounter of the mouse with the target
    L         = double([L_lattice,L_lattice]);
    food_site = import.sorw_get_linear_index_from_experiment_lattice(L,r_target);
    p         = model.sorw_GetSimulationParam('N',L,[],'circle',NaN,NaN,NaN,NaN,food_site,stop_at_food,'',NaN,false);
end