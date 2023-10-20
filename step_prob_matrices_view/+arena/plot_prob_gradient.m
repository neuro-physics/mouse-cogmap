function [qh,ph,food_start_ph,ax,X,Y,G] = plot_prob_gradient(ax,sites,simParam,use_grid_visits_as_color,colorMap,quiverArgs,pcolorArgs,startArgs,targetArgs,showPreviousTarget,prevTargetArgs,showGradientMagnitude,sites_jackknife,show_jk_avg,calc_significant_path_args,use_color_quiver)
% [h_sites,h_steps,food_start_ph] = plot_arena(ax,sites,simParam,colorMapSites,colorMapSteps,minmaxSiteMarkerSize,minmaxStepLineWidth,siteArgs,stepArgs)
    if isempty(ax)
        fh = figure;
        ax = axes;
    end
    if (nargin < 3) || isempty(simParam)
        L_sqrt = ceil(sqrt(numel(sites)));
        simParam = struct('start_pos','N','shape','circle','L',[L_sqrt,L_sqrt],'food_site',[1,1]);
    end
    if (nargin < 4) || isempty(use_grid_visits_as_color)
        use_grid_visits_as_color = false;
    end
    if (nargin < 5) || isempty(colorMap)
        colorMap = @jet;
    end
    if (nargin < 6) || isempty(quiverArgs)
        quiverArgs = {};
    end
    if (nargin < 7) || isempty(pcolorArgs)
        pcolorArgs = {};
    end
    if (nargin < 8) || isempty(startArgs)
        startArgs = {};
    end
    if (nargin < 9) || isempty(targetArgs)
        targetArgs = {};
    end
    if (nargin < 10) || isempty(showPreviousTarget)
        showPreviousTarget = false;
    end
    if (nargin < 11) || isempty(prevTargetArgs)
        prevTargetArgs = {};
    end
    if (nargin < 12) || isempty(showGradientMagnitude)
        showGradientMagnitude = true;
    end
    if (nargin < 13) || isempty(sites_jackknife)
        sites_jackknife = {};
    end
    if (nargin < 14) || isempty(show_jk_avg)
        show_jk_avg = false;
    end
    if (nargin < 15) || isempty(calc_significant_path_args)
        calc_significant_path_args = {30*pi/180,'mean'}; % refer to arena.calc_significant_path
    end
    if (nargin < 16) || isempty(use_color_quiver)
        use_color_quiver = true;
    end
    
    if use_color_quiver
        showGradientMagnitude = false;
    end
    
    startArgs      = func.get_args_set_default(startArgs     ,'DisplayName','start'      ,'MarkerSize',8,'Marker','s','MarkerFaceColor','none','Color','w','LineWidth',3,'Padding',[0,-0.5]);
    targetArgs     = func.get_args_set_default(targetArgs    ,'DisplayName','target'     ,'MarkerSize',5,'Marker','s','MarkerFaceColor','none','Color','w','LineWidth',3,'Padding',[0,0]);
    prevTargetArgs = func.get_args_set_default(prevTargetArgs,'DisplayName','target_prev','MarkerSize',5,'Marker','s','MarkerFaceColor','none','Color',[34,201,98]./255,'LineWidth',3,'Padding',[0,0]);
    
    step_val = cell2mat(arrayfun(@(s)s.p(:)',sites,'UniformOutput',false));
    if isa(colorMap,'function_handle')
        colorMap = colorMap(numel(step_val));
    end
    
    pcolor_facecolor = func.getParamValue('facecolor',pcolorArgs);
    dx_pcolor = 0;
    dy_pcolor = 0;
    if ~isempty(pcolor_facecolor)
        if strcmpi(pcolor_facecolor,'flat')
            dx_pcolor = -0.5;
            dy_pcolor = -0.5;
        end
    end
    if use_grid_visits_as_color
        dx_pcolor = -0.5;
        dy_pcolor = -0.5;
    end
    
    %c_steps_transf = getTransformToIndex(step_val,size(colorMap,1));
    %sz_steps_transf = getLinearTransform(step_val, minmaxStepLineWidth);
    [y,x] = ind2sub(simParam.L,(1:numel(sites))'); % lattice position (m,n) for site i
    [u,v] = arena.calc_prob_gradient(sites,simParam.L);
    G     = [u,v]; % gradient vector G(i,:) -> gradient at x(i),y(i)
    if ~isempty(sites_jackknife)
        [Gm,k_significant] = arena.calc_significant_path(sites_jackknife,calc_significant_path_args{:});
        if show_jk_avg
            G = Gm;
        else
            G(~k_significant,:) = 0;
        end
        u = G(:,1);
        v = G(:,2);
    end
    hold(ax,'on');
    ph=gobjects;
    if use_grid_visits_as_color
        p_visit = [sites(:).x];
        p_visit = p_visit./sum(p_visit);
        X = func.expandMatrix(reshape(x,simParam.L)-0.5,simParam.L+1);
        X(end,:) = X(end-1,:);
        X(:,end) = X(:,end-1)+1;
        Y = func.expandMatrix(reshape(y,simParam.L)-0.5,simParam.L+1);
        Y(:,end) = Y(:,end-1);
        Y(end,:) = Y(end-1,:)+1;
        C = func.expandMatrix(reshape(p_visit,simParam.L),simParam.L+1);
        if showGradientMagnitude
            ph=pcolor(ax,X+dx_pcolor,Y+dy_pcolor,C);
        end
    else
        X  = func.repeat_edges(reshape(x,simParam.L));
        Y  = func.repeat_edges(reshape(y,simParam.L));
        C  = func.repeat_edges(reshape(vecnorm(G')',simParam.L));
        Y(1,:)   = Y(2,:)     - 1;
        Y(end,:) = Y(end-1,:) + 1;
        X(:,1)   = X(:,2)     - 1;
        X(:,end) = X(:,end-1) + 1;
        C(1,:)   = zeros(1,size(C,2));
        C(end,:) = zeros(1,size(C,2));
        C(:,1)   = zeros(size(C,1),1);
        C(:,end) = zeros(size(C,1),1);
        if showGradientMagnitude
            ph = pcolor(ax,X+dx_pcolor,Y+dy_pcolor,C);
            ph.FaceColor='interp';
        end
    end
    if showGradientMagnitude
        ph.EdgeColor='none';
        if ~isempty(pcolorArgs)
            set(ph,pcolorArgs{:});
        end
        colormap(ax,colorMap);
    end
    % https://www.mathworks.com/matlabcentral/answers/828465-quiver-with-color-add-on % color each quiver arrow differently
    
    if use_color_quiver
        qh = plot_func.quivercolor(ax,x,y,u,v,vecnorm(G')',colorMap,'LineWidth',1.4,quiverArgs{:});
    else
        [scale_factor,quiverArgs] = func.getParamValue('scale',quiverArgs,true); % deletes color from varargin
        if isempty(scale_factor)
            qh = quiver(ax,x,y,u,v,'LineWidth',1.4,'Color','k',quiverArgs{:});
        else
            qh = quiver(ax,x,y,u,v,scale_factor,'LineWidth',1.4,'Color','k',quiverArgs{:});
        end
    end
    
    food_ph  = plot_func.plot_lattice_site(ax,simParam.L,simParam.food_site,targetArgs{:});
    start_ph = plot_func.plot_lattice_site(ax,simParam.L,arena.get_start_position(simParam.start_pos,simParam.shape,simParam.L),startArgs{:});

    prev_ph = [];
    if showPreviousTarget
        [site_pos,prevTargetArgs]   = func.getParamValue('LatticeSitePosition',prevTargetArgs,true);
        prev_ph = plot_func.plot_lattice_site(ax,simParam.L,site_pos,prevTargetArgs{:});
    end
    
    food_start_ph = [start_ph,food_ph,prev_ph];
    
    axis(ax,'square');
    daspect(ax,[1,1,1]);
    %set(ax,'YDir','reverse','Box','on');
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

