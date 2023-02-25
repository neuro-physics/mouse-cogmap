function h=myplotv(G,x0y0,varargin)
% plots all vectors in G starting from the origin using quiver
% G -> a collection of vectors (1 x,y vector per row)
    if (nargin < 2) || isempty(x0y0)
        x0y0 = [0,0];
    end
    ax_ind = find(strcmpi(cellfun(@class,varargin,'UniformOutput',false),'matlab.graphics.axis.Axes'));
    if isempty(ax_ind)
        ax = gca;
    else
        ax = varargin{ax_ind};
        varargin(ax_ind) = [];
    end
    h=quiver(ax,x0y0(1).*ones(size(G,1),1),x0y0(2).*ones(size(G,1),1),G(:,1),G(:,2),varargin{:});
end
