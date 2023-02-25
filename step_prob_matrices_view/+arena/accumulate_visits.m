function s = accumulate_visits(sites_per_run,return_as_matrix)
    if (nargin < 2) || isempty(return_as_matrix)
        return_as_matrix = false;
    end
    assert(iscell(sites_per_run),'sites_per_run must be a cell array');
    s = cell(size(sites_per_run));
    Gk = arena.calc_grid_visit_matrix(sites_per_run{1});
    if return_as_matrix
        s{1} = Gk;
    else
        s{1} = sites_per_run{1};
    end
    for k = 2:numel(sites_per_run)
        Gk = Gk + arena.calc_grid_visit_matrix(sites_per_run{k});
        if return_as_matrix
            s{k} = Gk;
        else
            s{k} = model.sorw_GetSites(arena.calc_probability_matrix(sites_per_run{k}),arena.calc_numofsteps_matrix(sites_per_run{k}),Gk(:),false);
        end
    end
end