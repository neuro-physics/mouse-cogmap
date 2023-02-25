classdef (Sealed) AdjMatrixLinLatt < adjmatrix.AdjMatrix
    methods
        function this = AdjMatrixLinLatt(params, loadOnInit)
            % creates a complete graph (mean-field network)
            %
            % params {AdjMatrixParams}: params of the adjacency matrix
            % loadOnInit {boolean}: loads the text file containing the adj matrix on initialization (constructor)
            this = this@adjmatrix.AdjMatrix(params);
            if (nargin > 1)
                if (loadOnInit)
                    this.Load();
                end
            end
        end
        
        function this = Load(this)
            if (this.Params.isPer)
                i = [ 1 ];
                j = [ this.Params.N ];
            else
                i = [];
                j = [];
            end
            for n = 2:this.Params.N
                i(end+1) = n;
                j(end+1) = n - 1;
            end
            this.Matrix = sparse(i, j, ones(1,length(i)), this.Params.N, this.Params.N);
            if (~this.Params.isDir)
                this.Matrix = this.Matrix + sparse(j, i, ones(1,length(i)), this.Params.N, this.Params.N);
            end
        end
    end
end