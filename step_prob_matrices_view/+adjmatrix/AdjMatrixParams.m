classdef (Sealed) AdjMatrixParams
    % defines the available parameters for an adjacency matrix
    properties (SetAccess = private, GetAccess = public)
        Type = adjmatrix.NetworkTypes.SqrLatt; % network type
        N = 400; % number of elements
        L = [ 20 20 1 ]; % linear dimension (sqr latt: number of elements in a row... N = prod_i L_i)
        p = 0.02; % probability. depending on type, it can have different meaning
        m = 3; % neighbors. depending on type, it can have different meaning
        isDir = 0; % is directed?
        isPer = 0; % is periodic?
        Dim = 2;
        FileName = '';
        Delimiter = ' ';
        NHeader = 0;
        isCircSqr = false; % flag to tell if network is a circular square lattice
    end

    methods
        function this = AdjMatrixParams(type, NorL, p, m, isDir, isPer, dim, fileName, delimiter, nHeader, isCircularSqr)
            % Create a parameter object for creating a network adjacency
            % matrix.
            %
            % If no argument is passed, the default parameters are used.
            %
            %       NorL {int} or {int(3)}: number of elements in the network (scalar) or linear size of each dimension of the lattice (vector(3))
            %       p {double}:
            %           for WS -> rewiring probability
            %           for Rnd -> probability of adding an edge
            %           for HK -> probability of adding a triangle after the addition of a node
            %       m {int}:
            %               for BA -> number of edges of every new node
            %               for WS -> number of neighbors for the initial graph
            %               for HK -> number of random edges for every new node
            %       isDir {boolean}: is directed?
            %       isPer {boolean}: is periodic?
            %       dim {int}: dimension of the lattice network (if dim is given, then N must be given, or length(L) = dim
            %       circSqrLattRad {double} : radius of circular square lattice (if CircSqrLatt is chosen)
            if (nargin < 11) || isempty(isCircularSqr)
                isCircularSqr = 0;
            end
            if (nargin ~= 0)
                this.Type = type;
                if (nargin > 7)
                    this.FileName = fileName;
                    this.Delimiter = delimiter;
                    this.NHeader = nHeader;
                end
                sNorL = size(NorL);
                if (~(sNorL(1) == sNorL(2) == 1))
                    if (length(find(NorL ~= 1)) ~= dim) % couting only the dimensions of L which are ~= 1
                        throw(MException('AdjMatrixParams:LatticeDimension', 'Lattice dimension dim = %g must be equal to Length(L) = %g', dim, length(NorL)));
                    end
                    this.L = NorL;
                    this.N = prod(this.L);
                else
                    this.N = NorL;
                    Lx = NorL .^ (1 / dim);
                    if (~isinteger(Lx))
                        if (this.Type.IsLattice())
                            throw(MException('AdjMatrixParams:NumberOfElements', 'Number of elements must be N=L^dim, with L integer for the desired type of network. If you want Lx ~= Ly ~= Lz, specify L vector instead.'));
                        end
                    end
                    this.L = ones(1, dim) .* Lx;
                end
                this.p = p;
                this.m = m;
                this.isDir = isDir;
                this.isPer = isPer;
                this.Dim = dim;
                this.isCircSqr = isCircularSqr;
                if (this.Type.IsLattice())
                    if (~this.Type.IsValidLattice(dim))
                        throw(MException('AdjMatrixParams:LatticeDimension', 'The dimension dim = %g is not compatible with the chosen network type = %s', dim, char(this.Type)));
                    end
                end
            end
        end
        
        function bol = IsLEqualForDir(this)
            bol = 1;
            n = length(this.L);
            for i = 2:n
                if (this.L(i-1) ~= this.L(i))
                    bol = 0;
                    return;
                end
            end
        end
    end
end