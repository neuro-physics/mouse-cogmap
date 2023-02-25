function ph = plot_square_circular_hole(ax,r_center,R,square_offset,varargin)
    t        = linspace(0,2.*pi,10000);
    t        = t(1:(end-1));
    x0       = r_center(1);
    y0       = r_center(2);
    x_circle = x0 + R.*cos(t);
    y_circle = y0 + R.*sin(t);
    x        = [ max(x_circle)+square_offset, max(x_circle)+square_offset, min(x_circle)-square_offset, min(x_circle)-square_offset, max(x_circle)+square_offset, x_circle];
    y        = [ max(y_circle)+square_offset, min(y_circle)-square_offset, min(y_circle)-square_offset, max(y_circle)+square_offset, max(y_circle)+square_offset, y_circle];
    ph       = fill(ax,x,y,'k');
    if numel(varargin) > 0
        set(ph,varargin{:});
    end
end