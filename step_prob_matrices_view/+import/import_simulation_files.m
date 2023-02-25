function si = import_simulation_files(fileNamePtrn,sort_by_par)
    if (nargin < 2) || isempty(sort_by_par)
        sort_by_par = '';
    end
    f = dir(fileNamePtrn);
    assert(numel(f)>0,'No file found that matched the pattern');
    fn = fullfile(f(1).folder,f(1).name);
    si(1) = import_single_file(fn);
    for k = 2:numel(f)
        fn = fullfile(f(k).folder,f(k).name);
        si(k) = import_single_file(fn);
    end
    
    if ~isempty(sort_by_par)
        assert(isfield(si(1).simParam,sort_by_par),'sort_by_par must be a field in the simParam struct')
        [~,k] = sort(func.get_par_from_substruct(si,'simParam',sort_by_par));
        si = si(k);
    end
end

function si = import_single_file(fn)
    si_temp = load(fn);
    si = func.copy_struct_fields(si_temp.simParam,{'L','w','alpha','xi','nu'},si_temp);
    si.L = si.L(1);
    if is_cell_of_cells(si.sites_per_run)
        P = arena.accumulate_prob(cellfun(@(c)c{1},si.sites_per_run,'UniformOutput',false),true); % all trials have the same probablity, so we accumulate only trial 1
        G = cellfun(@(c)reshape(arena.accumulate_visits(c,true),[],1),si.sites_per_run,'UniformOutput',false);
        N = cellfun(@(c)arena.accumulate_steps(c,true),si.sites_per_run,'UniformOutput',false);
        n = numel(P);
        si.sites_per_run_cprob = cell(size(si.sites_per_run));
        for i = 1:n
            si.sites_per_run_cprob = model.sorw_GetSites(P{i},N{i},G{i},false);
        end
    else
        si.sites_per_run_cprob = arena.accumulate_prob(si.sites_per_run);
    end
end

function r = is_cell_of_cells(c)
    r = iscell(c);
    if r
        r = r && iscell(c{1});
    end
end