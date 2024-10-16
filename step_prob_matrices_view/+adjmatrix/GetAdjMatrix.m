function mat = GetAdjMatrix(params, delAfterLoad)
    % params {AdjMatrixParams}: specify the desired parameters;
    % delAfterLoad {boolean}: if true, txt file generated by networkX will be deleted after loading the matrix
    %
    % performs an external call to Python package networkX, which creates
    % an adjacency matrix in a text file. Reads the text file and
    % returns an sparse matrix with the connections
    switch (params.Type)
        case adjmatrix.NetworkTypes.LinLatt
            am = adjmatrix.AdjMatrixLinLatt(params, 1);
        case adjmatrix.NetworkTypes.SqrLatt
            am = adjmatrix.AdjMatrixSqrLatt(params, 1);
        case adjmatrix.NetworkTypes.CircSqrLatt
            am = adjmatrix.AdjMatrixCircSqrLatt(params, 1);
        case adjmatrix.NetworkTypes.CubLatt
            am = adjmatrix.AdjMatrixGridGraph(params, 1, delAfterLoad);
        case adjmatrix.NetworkTypes.ComplGraph
            am = adjmatrix.AdjMatrixComplGraph(params, 1, delAfterLoad);
        case adjmatrix.NetworkTypes.BarabAlbGraph
            am = adjmatrix.AdjMatrixBarabAlbGraph(params, 1, delAfterLoad);
        case adjmatrix.NetworkTypes.HolmeKimPLGraph
            am = adjmatrix.AdjMatrixHolmeKimPLGraph(params, 1, delAfterLoad);
        case adjmatrix.NetworkTypes.WattsStrogGraph
            am = adjmatrix.AdjMatrixWattsStrogGraph(params, 1, delAfterLoad);
        case adjmatrix.NetworkTypes.ConnWaStGraph
            am = adjmatrix.AdjMatrixConnWaStGraph(params, 1, delAfterLoad);
        case adjmatrix.NetworkTypes.RndGraph
            am = adjmatrix.AdjMatrixRndGraph(params, 1, delAfterLoad);
        case adjmatrix.NetworkTypes.FromFile
            am = adjmatrix.AdjMatrixFromFile([], [], [], params, 1);
        otherwise
            throw(MException('AdjMatrix:GetAdjMatrix', 'unrecognized network type!'));
    end
    mat = am.Get();
end