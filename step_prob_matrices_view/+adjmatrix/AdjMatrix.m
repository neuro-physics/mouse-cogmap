classdef (Abstract = true) AdjMatrix < handle
    % base class for every adjacency matrix
    properties (Access = protected)
        Params;
        Matrix;
    end
    
    methods
        function this = AdjMatrix(params, matrix)
            % params {AdjMatrixParams}: parameters of the required adjacency
            % matrix {sparse matrix}: sparse matrix representing this adj matrix
            if (nargin == 1) % accepts constructor with no param
                this.Params = params;
            elseif (nargin == 2)
                if (issparse(matrix))
                    this.Matrix = matrix;
                else
                    this.Matrix = sparse(matrix);
                end
            else
                this.Params = AdjMatrixParams();
                this.Matrix = [];
            end
        end

        function mat = Get(this)
            mat = this.Matrix;
        end
    end
    
    methods (Abstract)
        this = Load
    end
end