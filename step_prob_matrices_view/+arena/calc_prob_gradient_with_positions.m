function [G,r] = calc_prob_gradient_with_positions(sites,L,invert_y,normalize)
    if (nargin < 3) || isempty(invert_y)
        invert_y = false;
    end
    if (nargin < 4) || isempty(normalize)
        normalize = false;
    end
    [y,x] = ind2sub(L,(1:numel(sites))'); % lattice position (m,n) for site i
    [u,v] = arena.calc_prob_gradient(sites,L,invert_y,normalize);
    G = [u,v]; % gradient vector G(i,:) -> gradient at x(i),y(i)
    r = [x,y];
end