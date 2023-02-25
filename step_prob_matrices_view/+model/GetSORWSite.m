function e = GetSORWSite(x0,indNeigh,p,n)
    % x -> state of this node
    % neigh -> col vector: list of neighbor indices of this node
    % p -> col vector: connection weight between this node and each neighbor in neigh list (probability of taking a step)
    % n -> col vector: number of steps from this node to each neighbor in neigh list
    if (nargin < 4) || isempty(n)
        n = [];
    end
    e = struct('x', 0.0, 'neigh', zeros(0,1), 'p', zeros(0,1), 'n', zeros(0,1));
    coder.varsize('e.neigh', 'e.p', 'e.n');
    if nargin ~= 0
        [~,s] = sort(p,'descend'); % sorting connections from the heaviest to the lightest
        e.x = x0;
        e.neigh = reshape(indNeigh(s),[],1);
        e.p = reshape(p(s),[],1);
        if isempty(n)
            e.n = zeros(size(e.p));
        else
            e.n = reshape(n(s),[],1);
        end
    end
end