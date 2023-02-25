function s = accumulate_steps(sites_per_run,return_as_matrix,return_total)
    if (nargin < 2) || isempty(return_as_matrix)
        return_as_matrix = false;
    end
    if (nargin < 3) || isempty(return_total)
        return_total = false;
    end
    assert(iscell(sites_per_run),'sites_per_run must be a cell array');
    if ~isstruct(sites_per_run{1})
        return_as_matrix = true;
        warning('accumulate_steps:return_as_matrix','forcing return_as_matrix == true because sites_per_run is cell of matrix instead of cell of sites struct');
    end
    s = cell(size(sites_per_run));
    Nk = get_num_of_steps_matrix(sites_per_run{1});
    if return_as_matrix
        s{1} = Nk;
    else
        s{1} = sites_per_run{1};
    end
    for k = 2:numel(sites_per_run)
        Nk = Nk + get_num_of_steps_matrix(sites_per_run{k});
        if return_as_matrix
            s{k} = Nk;
        else
            s{k} = model.sorw_GetSites(arena.calc_probability_matrix(sites_per_run{k}),Nk,[sites_per_run{k}.x],false);
        end
    end
    if return_total
        s = s{end};
    end
end

function Nk = get_num_of_steps_matrix(sites_per_run_item)
    if isstruct(sites_per_run_item)
        Nk = arena.calc_numofsteps_matrix(sites_per_run_item);
    else
        Nk = sites_per_run_item;
    end
end