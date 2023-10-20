function ph = circle_sector(ax,x0y0,R,theta,color,n_points,varargin)
% plots a circular sector centered at x0y0 = [x0, y0], with radius R, between angles theta(1) and theta(2)
% remaining args are forwarded to patch function via set(ph,varargin{:})
%
% returns patch handler
    assert(isnumeric(x0y0)  && (numel(x0y0) ==2),'x0y0 must be a 2d row vector')
    assert(isnumeric(R)     && (numel(R)    ==1),'R must be a scalar')
    assert(isnumeric(theta) && (numel(theta)==2),'theta must be a 2d row vector')
    varargin = func.get_args_set_default(varargin,'LineStyle','none');
    if isempty(ax)
        ax = gca;
    end
    if (nargin < 5) || isempty(color)
        color = 'r';
    end
    if (nargin < 6) || isempty(n_points)
        n_points = 100;
    end
    th = linspace(theta(1),theta(2),n_points);
    x  = [0,R.*cos(th),0] + x0y0(1);
    y  = [0,R.*sin(th),0] + x0y0(2);
    ph = patch(ax,x,y,color);
    if ~isempty(varargin)
        set(ph,varargin{:});
    end
end
