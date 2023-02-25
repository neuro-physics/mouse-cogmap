function s = prob_matrix_to_site_struct(si,P_matrix_label,idx)
% si -> struct result of import.import_simulation_files
%       with fields 'P_indpt' and 'P_cprob'
% P_matrix_label -> either 'P_indpt' and 'P_cprob'
%                  si.(P_matrix_label)
% idx -> index of the 'P_indpt' or 'P_cprob' cell array
%        if empty or not given, then converts all elements of si.(P_matrix_label)
    if (nargin < 3) || isempty(idx)
        idx = [];
    end
    if isempty(idx)
        s = cell(size(si.(P_matrix_label)));
        for i = 1:numel(s)
            s{i} = arena.prob_matrix_to_site_struct(si,P_matrix_label,i);
        end
    else
        s = model.sorw_GetSites(si.(P_matrix_label){idx}, arena.calc_numofsteps_matrix(si.sites_per_run{idx}), [si.sites_per_run{idx}.x], true);
    end
end