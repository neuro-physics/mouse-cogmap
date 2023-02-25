classdef (Abstract = true) AdjMatrixFromNetX < adjmatrix.AdjMatrixFromFile

    properties (Access = protected)
        Method;
    end

    methods
        function this = AdjMatrixFromNetX(method, params, loadOnInit, delAfterLoad)
            % creates an adjacency matrix with NetworkX
            %
            % method {String}: networkX method name
            % params {AdjMatrixParams}: relevant parameters
            % loadOnInit {boolean}: loads the matrix from the data file in constructor
            % delAfterLoad {boolean}: delete adj matrix file after loading the matrix

            n = num2str(randi(10, 1, 4) - 1); % generating random sequence of numbers for a random filename
            n = n(n ~= ' '); % removing whitespaces
            fileName = [ 'am' n '.' char(params.Type) '.tmp' ];
            this = this@adjmatrix.AdjMatrixFromFile(fileName, ' ', 0, params, 0);
            this.Method = method;
            this.CallNetX();
            if (nargin > 2)
                if (loadOnInit)
                    this.Load(delAfterLoad);
                end
            end
        end
        
    end
    
    methods (Access = private)
        function this = CallNetX(this)
            prefix = ''; % prefix used for linux or Mac OS X
            if ispc % running in windows
                prefix = 'cmd /c '; % in windows, one must furst call the cmd terminal to execute python commands
            elseif ~isunix % none of the above... fodeu!
                throw(MException('AdjMatrix:AdjMatrixFromNetX', 'OS is neither Windows nor UNIX-based.'));
            end
            
            cmdline = [ prefix 'python -c "import networkx as nx; import numpy as np; ' this.GetNetXGraphCmdLine() '; np.savetxt(''' this.FileName ''', ' this.GetNetXAdjMatCmdLine ',fmt=''%1d'')"' ];
            status = system(cmdline);
            if status %error
                throw(MException('Adjmatrix:NetworkXCall', 'There was an error trying to call python script NetworkX from MATLAB. Make sure you have numpy and networkx packages installed, and that python is in the Path.'));
            end
        end
    end
    
    methods (Access = protected, Abstract)
        cmd = GetNetXGraphCmdLine(this)
        cmd = GetNetXAdjMatCmdLine(this)
    end
end