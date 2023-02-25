function [ax,rh,ph] = plot_arena_circle(ax,simParam,plotArgs,arena_outside_patch_args)
    if (nargin < 1) || isempty(ax)
        figure;
        ax = axes;
    end
    if (nargin < 3) || isempty(plotArgs)
        plotArgs = {};
    end
    if (nargin < 4) || isempty(arena_outside_patch_args)
        arena_outside_patch_args = {};
    end
    plotArgs                 = func.get_args_set_default(plotArgs,'LineWidth',2,'EdgeColor','k','FaceColor',0.9.*ones(1,3));
    arena_outside_patch_args = func.get_args_set_default(arena_outside_patch_args,'HandleVisibility','off','EdgeColor','none','FaceColor','k');

    if strcmpi(simParam.shape,'circle')
        plotArgs = ['Curvature',[1,1],plotArgs];
        x0 = 0.5;
        y0 = 0.5;
        w = simParam.L(1);
        h = simParam.L(2);
        %L = simParam.L;
        %r = mean(L-1)/2-0.5;
        %w = 2.*r;
        %h = 2.*r;
    else
        x0 = 0;
        y0 = 0;
        w  = simParam.L(1)+1;
        h  = simParam.L(2)+1;
    end
    ph = plot_func.plot_square_circular_hole(ax,[x0+w/2,y0+h/2],mean([w/2,h/2]),2,arena_outside_patch_args{:});
    rh = rectangle('Position',[x0,y0,w,h],'HandleVisibility','off',plotArgs{:});
    %axis(ax,'square');
    %ax.XLim = [0,w];
    %ax.YLim = [0,h];
end