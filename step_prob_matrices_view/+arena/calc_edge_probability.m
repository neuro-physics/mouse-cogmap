function D = calc_edge_probability(sites)
% sites(i).p(k) is the outgoing probability from site i to j = sites(i).neigh(k)
%
% this function generates a matrix D such that
% D(i,j) = p(i,j) - p(j,i)
% is the average directionality between nodes i,j
%
    p = arena.calc_probability_matrix(sites);
    D = p + p'; % direction matrix
end