function p = calc_probability_matrix(sites)
% returns p(i,j) where p(i,j) is the probability of stepping from j to i
    N = numel(sites);
    ii = zeros(4*N,1);
    jj = zeros(4*N,1);
    pp = zeros(4*N,1);
    ctr = 0;
    for j = 1:N
        for k = 1:numel(sites(j).neigh)
            ctr = ctr + 1;
            ii(ctr) = sites(j).neigh(k);
            jj(ctr) = j;
            pp(ctr) = sites(j).p(k);
        end
    end
    p = sparse(ii(1:ctr),jj(1:ctr),pp(1:ctr),N,N);
end