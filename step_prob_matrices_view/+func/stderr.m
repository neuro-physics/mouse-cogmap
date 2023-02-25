function s = stderr(x,dim)
    if (nargin < 2) || isempty(dim)
        dim = 1;
    end
    if isvector(x)
        s = std(x) ./ sqrt(numel(x));
    else
        s = std(x,[],dim) ./ sqrt(size(x,dim));
    end
end