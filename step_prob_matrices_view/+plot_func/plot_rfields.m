function [ax,sh,fh,cmap] = plot_rfields(ax,space,rfield,simulation,spaceArgs,rfieldArgs)
    if (nargin < 5) || isempty(spaceArgs)
        spaceArgs = {};
    end
    if (nargin < 6) || isempty(rfieldArgs)
        rfieldArgs = {'LineWidth',1,'HandleVisibility','off'};
    end
    [ax,sh] = func.plot_space(ax,space,spaceArgs);
    hold(ax,'on');
    cmap = func.cmap_brewer(simulation.N_cells,2,true);
    fh = gobjects(size(rfield));
    for i = 1:numel(rfield)
        fh(i) = plot_rfield_int(ax,rfield(i),rfieldArgs,cmap(rfield(i).postElement+1,:));
    end
    hold(ax,'off');
end

function fh = plot_rfield_int(ax,rfield,rfieldArgs,c)
    fh = rectangle(ax,'Position',[rfield.x0-rfield.radius,rfield.y0-rfield.radius,2*rfield.radius,2*rfield.radius],'Curvature',[1,1],'EdgeColor',c,rfieldArgs{:});
end