function [th,ah] = plot_trajectory(ax,traj,simulation,plotArgs)
    if (nargin < 1) || isempty(ax)
        figure;
        ax = axes;
    end
    if (nargin < 4) || isempty(plotArgs)
        plotArgs = {'LineWidth',2};
    end
    th = gobjects(size(traj));
    ah = gobjects(size(traj));
    cmap = [ linspace(1,0.5,numel(traj))', zeros(numel(traj),2) ];
    hold(ax,'on');
    for i = 1:numel(traj)
        [th(i),ah(i)] = plot_traj_int(ax,traj(i),simulation.totalTime,cmap(i,:),i,plotArgs);
    end
    hold(ax,'off');
end

function [th,ah] = plot_traj_int(ax,traj,T,c,k,args)
    p0 = [traj.x0,traj.y0];
    p1 = p0 + [traj.vx,traj.vy].*T;
    th = line(ax,[p0(1),p1(1)],[p0(2),p1(2)],'Color',c,'DisplayName', sprintf('Mouse %d',k), args{:});
    r = 0.1.*(p1 - p0);%(p1 - p0)./norm(p1 - p0);
    %theta = func.get_angle(p0,p1);
    q0 = ((p1 - p0) ./ 2) - r./2;
    ah = func.arrow3(q0,q0+r,'r0',2,3,[],[],[],ax);
    set(ah,'FaceColor',c,'HandleVisibility','off');
end