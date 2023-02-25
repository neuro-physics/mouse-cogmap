function [latth,X,Y] = plot_lattice_grid(ax,sites,simParam,pcolorArgs)
% [h_sites,h_steps,food_start_ph] = plot_arena(ax,sites,simParam,colorMapSites,colorMapSteps,minmaxSiteMarkerSize,minmaxStepLineWidth,siteArgs,stepArgs)
    if isempty(ax)
        fh = figure;
        ax = axes;
    end
    if (nargin < 4) || isempty(pcolorArgs)
        pcolorArgs = {};
    end
    pcolorArgs  = func.get_args_set_default(pcolorArgs,'FaceColor','none','EdgeColor','w','EdgeAlpha',0.2);
    
    [y,x] = ind2sub(simParam.L,(1:numel(sites))'); % lattice position (m,n) for site i
    hold(ax,'on');
    p_visit  = [sites(:).x];
    p_visit  = p_visit./sum(p_visit);
    X        = func.expandMatrix(reshape(x,simParam.L)-0.5,simParam.L+1);
    X(end,:) = X(end-1,:);
    X(:,end) = X(:,end-1)+1;
    Y        = func.expandMatrix(reshape(y,simParam.L)-0.5,simParam.L+1);
    Y(:,end) = Y(:,end-1);
    Y(end,:) = Y(end-1,:)+1;
    C        = func.expandMatrix(reshape(p_visit,simParam.L),simParam.L+1);
    latth = pcolor(ax,X,Y,C);
    if ~isempty(pcolorArgs)
        set(latth,pcolorArgs{:});
    end
end

function [x,y] = getSquareAtSite(s,L)
    [y,x] = ind2sub(L,s);
    x = [x-0.5,x+0.5,x+0.5,x-0.5];
    y = [y-0.5,y-0.5,y+0.5,y+0.5];
end

function s = getLinearTransform(values_to_transf, output_range, minmax_of_values)
    if (nargin < 3) || isempty(minmax_of_values)
        minmax_of_values = minmax(values_to_transf(:)');
    end
    dy = output_range(2) - output_range(1);
    dx = minmax_of_values(2) - minmax_of_values(1);
    if dx == 0
        dx = 1;
    end
    s.a = dy / dx;
    s.b = output_range(1) - s.a*minmax_of_values(1);
    s.f = @(x)s.b+s.a.*x;
end

function s = getTransformToIndex(values_to_transf, num_of_outputs, minmax_of_values)
    if (nargin < 3) || isempty(minmax_of_values)
        minmax_of_values = minmax(values_to_transf(:)');
    end
    dy = num_of_outputs-1;
    dx = minmax_of_values(2) - minmax_of_values(1);
    if dx == 0
        dx = 1;
    end
    s.a = dy / dx;
    s.b = -s.a*minmax_of_values(1);
    s.nColors = num_of_outputs;
end

function y = getAllColorsIndex(values_to_color, nColors, mm)
    if (nargin < 3) || isempty(mm)
        mm = minmax(values_to_color(:)');
    end
    s = getTransformToIndex(values_to_color, nColors, mm);
    y = getColorIndex(values_to_color,s);
end

function y = getColorIndex(values_to_color,colorTransf)
    y = round(colorTransf.a.*values_to_color+colorTransf.b)+1;
    y(y<1) = 1;
    y(y>colorTransf.nColors) = colorTransf.nColors;
end

function [v,c] = getParamValue(par,c,del)
    if (nargin < 3) || isempty(del)
        del = false;
    end
    k = find(strcmpi(c,par));
    if isempty(k)
        v = [];
        return;
    end
    if k == numel(c)
        error(['missing parameter value for ', par]);
    end
    v = c{k+1};
    if del
        c(k:(k+1)) = [];
    end
end