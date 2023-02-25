function p = get_par_from_substruct(si,substruct_name,par_name)
    assert(isfield(si,substruct_name),'substruct_name must be a field of si');
    assert(isfield(si(1).(substruct_name),par_name),'par_name must be a field of si.(substruct_name)');
    n = numel(si);
    p = zeros(1,n);
    for k = 1:n
        p(k) = si(k).(substruct_name).(par_name);
    end
end