function [G,r] = calc_prob_gradient_with_positions(sites,L,invert_y,normalize,sites_jackknife,show_jk_avg,calc_significant_path_args)
    if (nargin < 3) || isempty(invert_y)
        invert_y = false;
    end
    if (nargin < 4) || isempty(normalize)
        normalize = false;
    end
    if (nargin < 5) || isempty(sites_jackknife)
        sites_jackknife = {};
    end
    if (nargin < 6) || isempty(show_jk_avg)
        show_jk_avg = false;
    end
    if (nargin < 7) || isempty(calc_significant_path_args)
        calc_significant_path_args = {45*pi/180,'mean',invert_y}; %refer to arena.calc_significant_path
    end
    if invert_y
        calc_significant_path_args    = get_default_cell(3,calc_significant_path_args);
        calc_significant_path_args{3} = invert_y;
    end
    
    [y,x] = ind2sub(L,(1:numel(sites))'); % lattice position (m,n) for site i
    [u,v] = arena.calc_prob_gradient(sites,L,invert_y,normalize);
    G = [u,v]; % gradient vector G(i,:) -> gradient at x(i),y(i)
    
    if ~isempty(sites_jackknife)
        [Gm,k_significant] = arena.calc_significant_path(sites_jackknife,calc_significant_path_args{:});
        if show_jk_avg
            G = Gm;
        else
            G(~k_significant,:) = 0;
        end
    end
    
    r = [x,y];
end

function r = get_default_cell(n_elem,default_values)
    r = cell(1,n_elem);
    for k = 1:numel(default_values)
        r{k} = get_element(default_values,k);
    end
end

function r = get_element(ce_arr,k)
    if numel(ce_arr)>=k
        r=ce_arr{k};
    else
        r=[];
    end
end