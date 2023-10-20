function qh = quivercolor(ax,x,y,u,v,colorVar,colorMap,varargin)
    if isempty(ax)
        ax = gca;
    end
    if (nargin < 5) || isempty(colorVar)
        colorVar = hypot(u(:),v(:)); % magnitude of vectors is the default color
    end
    varargin                 = func.get_args_set_default(varargin,'LineWidth',1.4);
    [~,varargin]             = func.getParamValue('color',varargin,true); % deletes color from varargin
    [scale_factor,varargin]  = func.getParamValue('scale',varargin,true); % deletes color from varargin
    [max_head_size,varargin] = func.getParamValue('MaxHeadSize',varargin,true); % deletes color from varargin
    
    colormap(ax,colorMap);
    
    color_norm = (colorVar-min(colorVar))./range(colorVar);
    color_ind  = round(color_norm .* (size(colorMap,1)-1)) + 1; 
    
    qh = gobjects(1,0);
    for k = 1:numel(x)
        if isempty(scale_factor)
            qh(end+1) = quiver(ax,x(k),y(k),u(k),v(k),'Color',colorMap(color_ind(k),:),varargin{:});
        else
            qh(end+1) = quiver(ax,x(k),y(k),u(k),v(k),scale_factor,'Color',colorMap(color_ind(k),:),varargin{:});
        end
    end
    
    if ~isempty(max_head_size)
        set(qh,'MaxHeadSize',max_head_size);
    end
end