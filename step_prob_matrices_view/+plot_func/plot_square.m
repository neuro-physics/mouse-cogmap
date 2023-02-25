function pt = plot_square(ax,x_boundary,y_boundary,stretch_ratio,color,varargin)
    if (nargin < 4) || isempty(stretch_ratio)
        stretch_ratio = 1.5;
    end
    if (nargin < 5) || isempty(color)
        color = 'r';
    end
    args = func.get_args_set_default(varargin,'FaceColor','none','EdgeColor',color,'LineWidth',2);
    [x_ax_patch,y_ax_patch] = get_square_vertices(mean(x_boundary),mean(y_boundary),stretch_ratio.*abs(diff(x_boundary)),stretch_ratio.*abs(diff(y_boundary)));
    pt=patch(ax,x_ax_patch,y_ax_patch,color);
    set(pt,args{:});
end

function [x,y] = get_square_vertices(x0,y0,w,h)
% x0,y0 -> square center
% w,h   -> square width and height
    x = [ (x0 - w/2).*ones(1,2), (x0 + w/2).*ones(1,2) ];
    y = [ (y0 - h/2),(y0 + h/2) ];
    y = [ y,fliplr(y) ];
end