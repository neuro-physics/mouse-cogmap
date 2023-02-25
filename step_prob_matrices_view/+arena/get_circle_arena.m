function A = get_circle_arena(L)
    %L must be odd
    if any(mod(L,2)==0)
        error('each element of L must be odd, so that each side of the arena has a center')
    end

    L = func.repeatToComplete(L,2);

    % creating network parameters object    
    netPar = adjmatrix.AdjMatrixParams(adjmatrix.NetworkTypes.CircSqrLatt, L, 0.02, 3, 0, 0, 2, '', '', 0,true); % open boundary circular square lattice

    % getting the required adjacency matrix (results in a sparse matrix object)
    A = adjmatrix.GetAdjMatrix(netPar, 1)./4; % all step probabilities start as 1/4 -- a standard random walk
end