function r = copy_struct_fields(s,f,output_s)
    if (nargin < 3) || isempty(output_s)
        output_s = [];
    end
    assert(isempty(output_s) || isstruct(output_s),'output_s must be a struct where the fields f of s will be copied')
    if ~isempty(output_s)
        r = output_s;
    end
    fn = fieldnames(s);
    for i = 1:numel(fn)
        l = fn{i};
        if any(strcmpi(l,f))
            r.(l) = s.(l);
        end
    end
end