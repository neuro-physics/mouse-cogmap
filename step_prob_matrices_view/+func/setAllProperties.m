function obj = setAllProperties(obj,p,value)
    c = cell(1,numel(p)*2);
    c(1:2:end)=p;
    c(2:2:end)={value};
    set(obj,c{:});
end