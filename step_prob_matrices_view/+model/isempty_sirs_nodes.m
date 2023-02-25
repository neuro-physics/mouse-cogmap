function r = isempty_sirs_nodes(n)
    r = isempty(n) || is_vector_empty(n);
end

function r = is_vector_empty(n)
    r = is_empty_node(n(1));
    for i = 2:numel(n)
        r = r && is_empty_node(n(i));
    end
end

function r = is_empty_node(n)
    r = isempty(n.neigh) && all_zero_struct(n.par);
end

function r = all_zero_struct(par)
    f = fieldnames(par);
    l = f{1};
    r = isscalar(par.(l)) && (par.(l) == 0);
    for i = 2:numel(f)
        l = f{i};
        r = r && ( isscalar(par.(l)) && (par.(l) == 0) );
    end
end