function x = replaceValues(x,values,new_values)
% replaces all entries of each v in values in x by each entry in new_values
    assert(numel(values)==numel(new_values),'values and new_values must have the same number of elements');
    for k = 1:numel(values)
        x(x==values(k)) = new_values(k);
    end
end