function [th,lh] = set_point_label(ax,point_display_name,label,varargin)
    k = find(strcmpi(arrayfun(@(x)x.DisplayName,ax.Children,'UniformOutput',false),point_display_name),1,'first');
    lh = gobjects(1);
    th = gobjects(1);
    if ~isempty(k)
        lh = ax.Children(k);
        [pad,varargin] = func.getParamValue('Padding',varargin,true);
        if isempty(pad)
            pad = zeros(1,2);
        end
        th             = text(ax,lh.XData(1)+pad(1),lh.YData(1)+pad(2),label,varargin{:});
    end
end