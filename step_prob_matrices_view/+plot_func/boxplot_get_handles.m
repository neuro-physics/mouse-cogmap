function h = boxplot_get_handles(p,ax)
    if (nargin < 2) || isempty(ax)
        ax = gca;
    end
    h = gobjects(size(p));
    for i = 1:size(p,1)
        obj_struct = get(p(i,1));
        obj        = flipud(findobj(ax,'Tag',obj_struct.Tag));
        for j = 1:numel(obj)
            h(i,j) = obj(j);
        end
    end
end