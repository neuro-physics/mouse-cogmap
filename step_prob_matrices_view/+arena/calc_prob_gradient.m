function [u,v] = calc_prob_gradient(sites,L,invert_y,normalize)
% sites(i).p(k) is the outgoing probability from site i to j = sites(i).neigh(k)
% this function generates a vector field, u (horizontal), v (vertical), such that
%
% y-positive is pointing downwards (unless invert_y is set)
%
%
% u(i) = p(k,i) - p(j,i), where p(i,j) is the probability of going from j to i, and k and j are the right and left neighbors, respectively
% v(i) = p(k,i) - p(j,i), where k and j are the top and bottom neighbors, respectively
%
    if (nargin < 2) || isempty(L)
        L = [];
    end
    if (nargin < 3) || isempty(invert_y)
        invert_y = false;
    end
    if (nargin < 4) || isempty(normalize)
        normalize = false;
    end
    
    N = numel(sites);
    if (nargin < 2) || isempty(L)
        if floor(sqrt(N))~=sqrt(N)
            error('you have to provide L because sqrt(N) is not integer');
        end
        L = [sqrt(N),sqrt(N)];
    end
    u = zeros(N,1);
    v = zeros(N,1);
    for i = 1:N
        % position of the site i
        [y0,x0] = ind2sub(L,i);
        
        % position of the neighbors of i
        [y,x] = ind2sub(L,sites(i).neigh);
        
        % displacement from i to its neighbors
        dx = x - x0; % if dx > 0, neighbor is to the right, dx < 0, neighbor is to the left
        dy = y - y0; % dy > 0, neighbor is at the bottom, dy < 0, neighbor is at the top
        
        % little fix to ignore jumps of more than 1 step
        ind = (abs(dx)>1) | (abs(dy)>1);
        if any(ind)
            disp('WARNING: found irregular steps!')
        end
        dx(ind)=[];
        dy(ind)=[];
        
        % the difference between left and right, up and down step probabilities
        u(i) = get_value_or_0(sites(i).p(dx>0)) - get_value_or_0(sites(i).p(dx<0));
        v(i) = get_value_or_0(sites(i).p(dy>0)) - get_value_or_0(sites(i).p(dy<0));
        if invert_y 
            v(i) = -v(i);
        end
        
        if normalize
            G_norm = sqrt(u(i).^2+v(i).^2);
            u(i) = u(i) ./ G_norm;
            v(i) = v(i) ./ G_norm;
        end
    end
end

function r = get_value_or_0(s)
    if isempty(s)
        r = 0;
    else
        r = s;
    end
end