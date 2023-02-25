function s = accumulate_prob(sites_per_run,return_as_matrix,return_total)
    if (nargin < 2) || isempty(return_as_matrix)
        return_as_matrix = false;
    end
    if (nargin < 3) || isempty(return_total)
        return_total = false;
    end
    assert(iscell(sites_per_run),'sites_per_run must be a cell array');
    s = cell(size(sites_per_run));
    Pkm1 = arena.calc_probability_matrix(sites_per_run{1});
    if return_as_matrix
        s{1} = Pkm1;
    else
        s{1} = sites_per_run{1};
    end
    for k = 2:numel(sites_per_run)
        Pk = arena.calc_probability_matrix(sites_per_run{k});
        P = Pk + Pkm1 - Pk.*Pkm1; % accumulating according to the union of events at stages k-1 and k
        if return_as_matrix
            s{k} = P;
        else
            s{k} = model.sorw_GetSites(P,arena.calc_numofsteps_matrix(sites_per_run{k}),[sites_per_run{k}.x],false);
        end
        Pkm1 = P; % so that we accumulate all the stages up to k
    end
    if return_total
        s = s{end};
    end
end