function [v,c] = getParamValue(par,c,del,default_value)
    if (nargin < 3) || isempty(del)
        del = false;
    end
    if (nargin < 4) || isempty(default_value)
        default_value = [];
    end
    k = find(strcmpi(c,par));
    if isempty(k)
        v = default_value;
        return;
    end
    if k == numel(c)
        error(['missing parameter value for ', par]);
    end
    v = c{k+1};
    if del
        c(k:(k+1)) = [];
    end
end