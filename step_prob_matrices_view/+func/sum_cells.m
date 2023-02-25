function s = sum_cells(C,entries)
% sum all cells in cell arrays... all cells must be the same size
% numel(entries) == numel(C)
% if entries is specified,
%    if entries is logical vector, then sum only those entries of C where entries is true
%    if entries is numeric vector, then sum only those indices of C contained in entries
    if ~iscell(C)
        C = {C};
    end
    if (nargin < 2) || isempty(entries)
        entries = 1:numel(C);
    end
    if islogical(entries)
        entries = find(entries);
    end
    sz = size(C{entries(1)});
    s = sum(func.reshapeLines(func.matCell2Mat(C(entries)),sz,'3darray'),3);
end