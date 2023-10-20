function args = set_arg_in_cellarray(cell_with_args,varargin)
    n = numel(varargin);
    assert(mod(n,2)==0           ,'set_arg_in_cellarray :: varargin must have pairs of arguments and values');
    assert(iscell(cell_with_args),'set_arg_in_cellarray :: cell_with_args must be a cell with pairs of arguments and values')
    args = cell_with_args;
    m = numel(cell_with_args)+1;
    for i = 1:2:n
        a = varargin{i};
        v = varargin{i+1};
        k = find(strcmpi(cell_with_args,a),1,'first');
        if isempty(k) % the argument in varargin is not yet present in the cell_with_args
            % then we set its default value from varargin
            args{m}   = a;
            args{m+1} = v;
            m = m + 2;
        else
            args{k}   = a;
            args{k+1} = v;
        end
    end
end