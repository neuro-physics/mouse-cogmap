function [ax,rh] = plot_arena_circle(ax,mouse_track,plotArgs)
    if (nargin < 1) || isempty(ax)
        figure;
        ax = axes;
    end
    if (nargin < 3) || isempty(plotArgs)
        plotArgs = func.get_cell_set_default(plotArgs,'LineWidth',2,'EdgeColor','k','FaceColor',0.9.*ones(1,3));
    end
    %if (nargin < 4) || isempty(arena_outside_patch_args)
    %    arena_outside_patch_args = func.get_cell_set_default(arena_outside_patch_args,'HandleVisibility','off','EdgeColor','none','FaceColor','k');
    %end
    plotArgs = ['Curvature',[1,1],plotArgs];
    w = mouse_track.arena_diameter;
    h = mouse_track.arena_diameter;
    x0 = mouse_track.r_arena_center(1)-w/2;
    y0 = mouse_track.r_arena_center(2)-h/2;
    %ph = plot_func.plot_square_circular_hole(ax,[x0+w/2,y0+h/2],mean([w/2,h/2]),2,arena_outside_patch_args{:});
    rh = rectangle('Position',[x0,y0,w,h],'HandleVisibility','off',plotArgs{:});
    %axis(ax,'square');
    %ax.XLim = [0,w];
    %ax.YLim = [0,h];
end