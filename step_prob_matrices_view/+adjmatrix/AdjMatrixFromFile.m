classdef AdjMatrixFromFile < adjmatrix.AdjMatrix % handle makes this class being passed as reference instead of value
    % creates adjacency matrix from the specified text file
    properties (Access = protected)
        FileName;
        Delimiter;
        NHeader;
    end
    
    methods
        function this = AdjMatrixFromFile(fileName, delimiter, nHeader, params, loadOnInit)
            % creates an adjacency matrix from a file
            %
            % fileName {string}: name of the file
            % delimiter {string}: column delimiter character
            % nHeader {integer}: number of header lines in the file
            % loadOnInit {boolean}: if true, loads file content in constructor

            this = this@adjmatrix.AdjMatrix(params);
            if (~isempty(fileName))
                this.FileName = fileName;
                this.Delimiter = delimiter;
                this.NHeader = nHeader;
            else
                this.FileName = params.FileName;
                this.Delimiter = params.Delimiter;
                this.NHeader = params.NHeader;
            end
            if (nargin == 5)
                if (loadOnInit == 1) % the user wants to load the external matrix
                    this.Load(0);
                end
            end
        end
        
        function this = Load(this, delAfterLoad)
            % loads the adjacency matrix file into memory
            %
            % delAfterLoad {boolean}: delete file after loading?
            if (exist(this.FileName, 'file') == 2)
                this.Matrix = sparse(importdata(this.FileName, this.Delimiter, this.NHeader));
                if (delAfterLoad)
                    delete(this.FileName);
                end
            else
                throw(MException('AdjMatrix:LoadMatrixFromFile', 'Error loading file. File %s does not exist.', this.FileName));
            end
        end

        function str = GetFileName(this)
            str = this.FileName;
        end
    end
end

