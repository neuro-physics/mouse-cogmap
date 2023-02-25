classdef (Sealed) NetworkTypes
    % defines the available network types
    % as enumeration (available at R2013a)
    enumeration
        LinLatt,
        SqrLatt,
        CircSqrLatt,
        CubLatt,
        ComplGraph,
        BarabAlbGraph,
        HolmeKimPLGraph,
        WattsStrogGraph,
        ConnWaStGraph,
        RndGraph,
        FromFile;
    end
    
    methods
        function bol = IsLattice(this)
            bol = (this == adjmatrix.NetworkTypes.LinLatt) || (this == adjmatrix.NetworkTypes.SqrLatt)...
                || (this == adjmatrix.NetworkTypes.CubLatt) || (this == adjmatrix.NetworkTypes.CircSqrLatt);
        end
        
        function bol = IsValidLattice(this, dim)
            bol = 0;
            if (this == adjmatrix.NetworkTypes.LinLatt)
                bol = dim == 1;
            elseif (this == adjmatrix.NetworkTypes.SqrLatt)
                bol = dim == 2;
            elseif (this == adjmatrix.NetworkTypes.CubLatt)
                bol = dim == 3;
            elseif (this == adjmatrix.NetworkTypes.CircSqrLatt)
                bol = dim == 2;
            end
        end
    end
end