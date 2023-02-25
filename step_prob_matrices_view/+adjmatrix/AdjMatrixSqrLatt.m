classdef (Sealed) AdjMatrixSqrLatt < adjmatrix.AdjMatrix
    properties (Access = private)
        GetNeighbors;
    end
    
    methods
        function this = AdjMatrixSqrLatt(params, loadOnInit)
            % creates a complete graph (mean-field network)
            %
            % params {AdjMatrixParams}: params of the adjacency matrix
            % loadOnInit {boolean}: loads the text file containing the adj matrix on initialization (constructor)
            this = this@adjmatrix.AdjMatrix(params);
            if (this.Params.isPer)
                if (this.Params.isDir)
                    this.GetNeighbors = @(m,n) this.GetFixedNeighborsFree(m, n); % we want to generate a graph with free boundary conditions if it is directed
                else
                    this.GetNeighbors = @(m,n) this.GetFixedNeighborsPer(m, n);
                end
            else
                this.GetNeighbors = @(m,n) this.GetFixedNeighborsFree(m, n);
            end
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
                    v = this.GetNeighbors(m, n);
                    for vv = v
                        i(end+1) = k;
                        j(end+1) = vv;
                    end
                end
            end
            if ((Lx == 2) && (this.Params.isPer)) % in Lx = 2 periodic lattices, there are duplicate entries in i and j vectors
                n = length(i);
                ind = [];
                for k = 1:n
                    for l = k+1:n
                        if ((i(l) == i(k)) && (j(l) == j(k)))
                            ind(end+1) = l; % marking duplicated element index
                        end
                    end
                end
                i(ind) = []; % removing duplicate elements
                j(ind) = [];
            end
            this.Matrix = sparse(i, j, ones(1,length(i)), this.Params.N, this.Params.N);
            if (this.Params.isDir)
                this.Matrix = tril(this.Matrix);
                if (this.Params.isPer) % as the directed graph comes from a free boundary condition, we need to add the periodical conditions here
                    for m = 1:Lx
                        k1 = 1 + (m - 1) .* Lx;
                        this.Matrix(k1, k1 + Lx - 1) = 1; % the right-most column sends input to the left-most column
                        this.Matrix(m, Lx .* (Lx - 1) + m) = 1; % the bottom line sends input to the top line
                    end
                end
            end
        end
    end
    
    methods (Access = private)
        function v = GetFixedNeighborsPer(this, m, n)
            v = this.GetNeighborsIndex(m, n);
            if (m == 1) % first line connects to last line
                v(1) = this.Params.L(1) * (this.Params.L(1)-1) + n; % m = Lx - 1
            end
            if (m == this.Params.L(1)) % last line connects to the first line
                v(2) = n; % m = 0
            end
            if (n == 1) % first column connects to the last column
                v(3) = m * this.Params.L(1); % n = Lx - 1
            end
            if (n == this.Params.L(1)) % last column connects to the first column
                v(4) = (m - 1) * this.Params.L(1) + 1; % n = 0
            end
        end
        
        function v = GetFixedNeighborsFree(this, m, n)
            v = this.GetNeighborsIndex(m, n);
            ind = [];
            if (m == 1) % first line connects to last line
                ind(end+1) = 1;
            end
            if (m == this.Params.L(1)) % last line connects to the first line
                ind(end+1) = 2;
            end
            if (n == 1) % first column connects to the last column
                ind(end+1) = 3;
            end
            if (n == this.Params.L(1)) % last column connects to the first column
                ind(end+1) = 4;
            end
            v(ind) = [];
        end
        
        function v = GetNeighborsIndex(this, m, n)
            v = [ this.GetIndex(m-1,n) this.GetIndex(m+1,n) this.GetIndex(m,n-1) this.GetIndex(m,n+1) ];
        end
        
        function ind = GetIndex(this, m, n)
            %OLD
            ind = m + this.Params.L(1) .* (n - 1);
            %the sub2ind complains when m == 0
            %ind = sub2ind(this.Params.L,m,n);
            % the line below is the sub2ind output, which is equivalent to the one I used in the OLD line above
            %ndx = ndx + (double(v2) - 1).*siz(1);
        end
    end
end