function p = getAxAutoProperties(ax)
    p = fieldnames(ax);
    p(cellfun(@(x)ischar(ax.(x)) && strcmpi(ax.(x),'auto'),fieldnames(ax)) ~= 1) = [];
end