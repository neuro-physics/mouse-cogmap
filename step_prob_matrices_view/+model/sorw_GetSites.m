function sites = sorw_GetSites(A,Nstep,x0,normalizeProb)
% nodes of the arena in the self-organized random walk
% A       -> [N,N] adjacency matrix (either weighted or binary)
% A(i,j) = p_ij (probability of stepping from j to i)
% Nstep   -> matrix containing the number of steps from nodes j to i
% x0      -> value to assign to each site initial state (x); numel(x0) == size(A,1)
% normalizeProb -> if true, normalizes the probabilities in A (for fixed column, row-wise) when creating the sites
%
% returns a struct sites, such that
%   sites(j).x        -> state of this node (from x0 if given)
%   sites(j).neigh(k) -> col vector: index of neighbor k (nonempty rows in A(:,j) )
%   sites(j).p(k)     -> probability of stepping from site j to site sites(j).neigh(k), normalized if required
%   sites(j).n(k)     -> number of steps from j to sites(j).neigh(k), from Nstep if given
    if (nargin < 2) || isempty(Nstep)
        Nstep = [];
    end
    if (nargin < 3) || isempty(x0)
        x0 = 0.0;
    end
    if (nargin < 4) || isempty(normalizeProb)
        normalizeProb = true;
    end
    N = size(A,1);
    if (nargin == 1)
        if isscalar(A)
            N = A;
        end
    end
    N = int32(N);
    if isscalar(x0) || isvector(x0)
        x_init = func.repeatToComplete(x0, N);
    else
        x_init = reshape(x0,[],1);
    end
    sites = repmat(model.GetSORWSite(), 1, N);
    for j = 1:N
        ind = find(A(:,j));
        if normalizeProb
            pTotal = sum(A(ind,j));
            p = full(A(ind,j))./pTotal;
        else
            p = full(A(ind,j));
        end
        if isempty(Nstep)
            n = [];
        else
            n = full(Nstep(ind,j));
        end
        sites(j) = model.GetSORWSite(x_init(j),ind,p,n);
    end
end