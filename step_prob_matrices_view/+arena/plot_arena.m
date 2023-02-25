function [h_sites,h_steps,food_start_ph,ax] = plot_arena(ax,sites,simParam,colorMapSites,colorMapSteps,minmaxSiteMarkerSize,minmaxStepLineWidth,siteArgs,stepArgs)
    if isempty(ax)
        fh = figure;
        ax = axes;
    end
    if (nargin < 4) || isempty(colorMapSites) % if set to false, then does not plot sites
        colorMapSites = @jet;
    end
    if (nargin < 5) || isempty(colorMapSteps) % if set to false, then does not plot steps
        colorMapSteps = @jet;
    end
    if (nargin < 6) || isempty(minmaxSiteMarkerSize)
        minmaxSiteMarkerSize = [4,14];
    end
    if (nargin < 7) || isempty(minmaxStepLineWidth)
        minmaxStepLineWidth = [1,4.5];
    end
    if (nargin < 8) || isempty(siteArgs)
        siteArgs = {};
    end
    if (nargin < 9) || isempty(stepArgs)
        stepArgs = {};
    end
    
    colorSites = ~(islogical(colorMapSites) && (colorMapSites==false));
    colorSteps = ~(islogical(colorMapSteps) && (colorMapSteps==false));
    
    step_val = cell2mat(arrayfun(@(s)s.p(:)',sites,'UniformOutput',false));
    if isa(colorMapSites,'function_handle')
        colorMapSites = colorMapSites(numel(sites));
    end
    if isa(colorMapSteps,'function_handle')
        colorMapSteps = colorMapSteps(numel(step_val));
    end
    
    %[markerFaceColor,siteArgs] = getParamValue('markerfacecolor',siteArgs,true);
    c_sites_idx = getAllColorsIndex([sites.x],size(colorMapSites,1));
    c_steps_transf = getTransformToIndex(step_val,size(colorMapSteps,1));
    
    sz_sites_transf = getLinearTransform([sites.x], minmaxSiteMarkerSize);
    sz_steps_transf = getLinearTransform(step_val, minmaxStepLineWidth);
    
    h_sites = gobjects(1,numel(sites));
    h_steps = gobjects(1,numel(step_val));
    st_counter = 0;
    hold(ax,'on');
    for i = 1:numel(sites)
        [yi,xi] = ind2sub(simParam.L,i); % lattice position (m,n) for site i
        
        if colorSteps
            for k = 1:numel(sites(i).neigh)
                [yj,xj] = ind2sub(simParam.L,sites(i).neigh(k));
                x_s = [xi,xj];
                y_s = [yi,yj];
                if yj > yi % going down
                    x_s = x_s - 0.1;
                elseif yj < yi % going up
                    x_s = x_s + 0.1;
                end
                if xj > xi % going right
                    y_s = y_s + 0.1;
                elseif xj < xi % going left
                    y_s = y_s - 0.1;
                end
                c = getColorIndex(sites(i).p(k),c_steps_transf);
                st_counter = st_counter + 1;
                h_steps(st_counter) = line(ax,x_s,y_s,'Color',colorMapSteps(c,:),'LineWidth',sz_steps_transf.f(sites(i).p(k)),stepArgs{:});
            end
        end
        
        % plotting site
        if colorSites
            h_sites(i)=plot(ax,xi,yi,'s','Color',colorMapSites(c_sites_idx(i),:),'MarkerFaceColor',colorMapSites(c_sites_idx(i),:),'MarkerSize',sz_sites_transf.f(sites(i).x),siteArgs{:});
        end
    end
    if colorSites
        uistack(h_sites,'top');
    end
    
    [food_patch_x,food_patch_y] = getSquareAtSite(simParam.food_site,simParam.L);
    food_ph = patch(ax,food_patch_x,food_patch_y,'w');    food_ph.FaceColor = 'none';    food_ph.EdgeColor = 'w';    food_ph.LineWidth = 2;
    
    [start_x,start_y] = getSquareAtSite(arena.get_start_position(simParam.start_pos,simParam.shape,simParam.L),simParam.L);
    start_ph = patch(ax,start_x,start_y,'w');    start_ph.FaceColor = 'none';    start_ph.EdgeColor = 'w';    start_ph.LineWidth = 2;
    
    food_start_ph = [start_ph,food_ph];
    
    axis(ax,'square');
    daspect(ax,[1,1,1]);
    set(ax,'XLim',[0.5,simParam.L(1)+0.5],'YLim',[0.5,simParam.L(2)+0.5],'YDir','reverse','Box','on','Color','k');
    hold(ax,'off');
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