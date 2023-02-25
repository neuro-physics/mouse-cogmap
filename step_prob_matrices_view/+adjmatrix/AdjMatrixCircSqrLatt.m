classdef (Sealed) AdjMatrixCircSqrLatt < adjmatrix.AdjMatrix
    properties (Access = private)
        R;
    end
    
    methods
        function this = AdjMatrixCircSqrLatt(params, loadOnInit)
            % creates a complete graph (mean-field network)
            %
            % params {AdjMatrixParams}: params of the adjacency matrix
            % loadOnInit {boolean}: loads the text file containing the adj matrix on initialization (constructor)
            this = this@adjmatrix.AdjMatrix(params);
            if this.Params.L(1) ~= this.Params.L(2)
                error('L:AdjMatrixCircSqrLatt','The circular square lattice needs L(1) == L(2)');
            end
            if (this.Params.isPer)
                error('isPer:AdjMatrixCircSqrLatt','The circular square lattice cannot be periodic');
            end
            this.R = this.Params.L(1)/2;
            if (nargin > 1)
                if (loadOnInit)
                    this.Load();
                end
            end
        end
        
        function this = Load(this)
            Lx = this.Params.L(1);
            i = [];
            j = [];
            for m = 1:Lx
                for n = 1:Lx
                    k = this.GetIndex(m,n); % index of the element at column n and line m of the lattice
                    if isempty(k) % k is not inside the circle
                        continue;
                    end
                    v = this.GetNeighbors(m, n);
                    i(  (numel(i) + 1):(numel(i)+numel(v)) ) = k.*ones(1,numel(v));
                    j(  (numel(j) + 1):(numel(j)+numel(v)) ) = v;
                    %for vv = v
                    %    i(end+1) = k;
                    %    j(end+1) = vv;
                    %end
                end
            end
            this.Matrix = sparse(i, j, ones(1,length(i)), this.Params.N, this.Params.N);
            if (this.Params.isDir)
                this.Matrix = tril(this.Matrix);
            end
        end
    end
    
    methods (Access = private)
        
        function r = IsInsideCircle(this,y,x)
            % if any of the square's corners is inside the circle, then the square is inside the circle
            r = (((y-this.R).^2 + (x-this.R).^2) <= this.R.^2) | (((y-this.R-1.0).^2 + (x-this.R-1.0).^2) <= this.R.^2) | (((x-this.R-1.0).^2+(y-this.R).^2) <= this.R.^2) | (((x-this.R).^2+(y-this.R-1.0).^2) <= this.R.^2);
            % the line below says that a square is in the circle if its center is inside the circle
            %r = (y-this.R-0.5).^2 + (x-this.R-0.5).^2 <= this.R.^2;
        end
        
        function v = GetNeighbors(this, y, x)
            %v = [ this.GetIndex(m-1,n) this.GetIndex(m+1,n) this.GetIndex(m,n-1) this.GetIndex(m,n+1) ];
            v = this.GetIndex([y-1,y+1,y,y],[x,x,x-1,x+1]);
        end
        
        function ind = GetIndex(this, y, x)
            %OLD
            ind = y + this.Params.L(1) .* (x - 1);
            %the sub2ind complains when m == 0
            %ind = sub2ind(this.Params.L,m,n);
            ind(~this.IsInsideCircle(y,x)) = [];
            % the line below is the sub2ind output, which is equivalent to the one I used in the OLD line above
            %ndx = ndx + (double(v2) - 1).*siz(1);
        end
    end
end