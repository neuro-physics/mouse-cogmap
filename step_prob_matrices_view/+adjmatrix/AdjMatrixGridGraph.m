classdef (Sealed) AdjMatrixGridGraph < adjmatrix.AdjMatrixFromNetX
    methods
        function this = AdjMatrixGridGraph(params, loadOnInit, delAfterLoad)
            % creates a complete graph (mean-field network)
            %
            % params {AdjMatrixParams}: params of the adjacency matrix
            % loadOnInit {boolean}: loads the text file containing the adj matrix on initialization (constructor)
            % delAfterLoad {boolean}: delete adj matrix file after loading the matrix
            
            this = this@adjmatrix.AdjMatrixFromNetX('grid_graph', params, loadOnInit, delAfterLoad);
        end
    end
    methods (Access = protected)
        function cmd = GetNetXGraphCmdLine(this)
            Lstr = regexprep(num2str(this.Params.L), '\s+', ','); % returns the string Lstr = 'Lx,Ly,Lz'
            if (this.Params.isPer)
                isPerStr = 'True';
            else
                isPerStr = 'False';
            end
            cmd = [ 'G=nx.' this.Method '(dim=[' Lstr '],periodic=' isPerStr ')' ];
        end
        
        function cmd = GetNetXAdjMatCmdLine(this)
            cmd = 'nx.adj_matrix(G,nodelist=sorted(G.nodes())).todense()';
        end
    end
end