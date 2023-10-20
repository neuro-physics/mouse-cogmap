clearvars
close all

save_output_figures = false;
outputDir           = '../figs/paper/step_prob_typical_mouse/jackknife';

%% example of angles comparison

close all

deg = 180/pi;
theta_threshold = 5;

% 10 vectors that have a preferential direction uniformly within 5 degrees around 45 degrees
theta1 = ((2.*rand(10,1)-1).*theta_threshold.*pi/180)+(pi/4);
v1     = (0.5.*repmat(rand(10,1),1,2) + 0.5).*[cos(theta1),sin(theta1)];

% 10 vectors that have random angles from 0 to 2pi
theta2 = (2.*rand(10,1)-1).*pi;
v2     = (0.5.*repmat(rand(10,1),1,2) + 0.5).*[cos(theta2),sin(theta2)];

% mean vectors
v1m = mean(v1,1);
v2m = mean(v2,1);

% shifting angles of random vectors, such that the mean is at 0 degrees
v1r = func.rotate_vectors(v1,-func.angle_between_vectors(v1m,[1,0],false));
v2r = func.rotate_vectors(v2,-func.angle_between_vectors(v2m,[1,0],false));

v1mr = func.rotate_vectors(v1m,-func.angle_between_vectors(v1m,[1,0],false));
v2mr = func.rotate_vectors(v2m,-func.angle_between_vectors(v2m,[1,0],false));

% plotting vectors
fh = figure('Position',[10,10,1400,400]);

ax1=subplot(1,3,1);
hold(ax1,'on');
plot_func.myplotv(v1 ,[4,3],ax1,'DisplayName','Static JK sample');
plot_func.myplotv(v2 ,[4,3],ax1,'DisplayName','Random JK sample');
plot_func.myplotv(v1m,[4,3],ax1,'DisplayName','Static JK mean','Color','b','LineWidth',2,'MaxHeadSize',0.5);
plot_func.myplotv(v2m,[4,3],ax1,'DisplayName','Random JK mean','Color','r','LineWidth',2,'MaxHeadSize',1);
xlabel(ax1,'x','FontSize',15,'FontWeight','bold');
ylabel(ax1,'y','FontSize',15,'FontWeight','bold');
title(ax1,{'Jackknife sample','at (x,y)=(4,3)'})
axis square
daspect(ax1,[1,1,1]);
plot_func.plotVerticalLines(  ax1,4,'LineWidth',1,'LineStyle',':','Color','k','HandleVisibility','off');
plot_func.plotHorizontalLines(ax1,3,'LineWidth',1,'LineStyle',':','Color','k','HandleVisibility','off');
%ax1.XTickLabel = arrayfun(@(xx)num2str(xx+4,'%g'),ax1.XTick,'UniformOutput',false);
%ax1.YTickLabel = arrayfun(@(yy)num2str(yy+3,'%g'),ax1.YTick,'UniformOutput',false);
%lh=legend(ax1,'Location','best');

% plotting vectors (both groups have angle of the mean vector == 0)
ax2=subplot(1,3,2);
hold(ax2,'on');
plot_func.myplotv(v1r ,[4,3],ax2,'DisplayName','Static JK sample');
plot_func.myplotv(v2r ,[4,3],ax2,'DisplayName','Random JK sample');
plot_func.myplotv(v1mr,[4,3],ax2,'DisplayName','Static JK mean','Color','b','LineWidth',2,'MaxHeadSize',0.5);
plot_func.myplotv(v2mr,[4,3],ax2,'DisplayName','Random JK mean','Color','r','LineWidth',2,'MaxHeadSize',1);
xlabel(ax2,'x','FontSize',15,'FontWeight','bold');
ylabel(ax2,'y','FontSize',15,'FontWeight','bold');
title(ax2,{'Unbiased jackknife sample','at (x,y)=(4,3)'})
axis square
daspect(ax2,[1,1,1]);
plot_func.plotVerticalLines(  ax2,4,'LineWidth',1,'LineStyle',':','Color','k','HandleVisibility','off');
plot_func.plotHorizontalLines(ax2,3,'LineWidth',1,'LineStyle',':','Color','k','HandleVisibility','off');
%ax2.XTickLabel = arrayfun(@(xx)num2str(xx+4,'%g'),ax2.XTick,'UniformOutput',false);
%ax2.YTickLabel = arrayfun(@(yy)num2str(yy+3,'%g'),ax2.YTick,'UniformOutput',false);
lh=legend(ax2,'Position',[0.3066 0.7881 0.1204 0.2058]);

% angles relative to the mean vector (-pi to 0 are to the right; 0 to pi are to the left)
%t1 = atan2(v1r(:,2),v1r(:,1));
%t2 = atan2(v2r(:,2),v2r(:,1));

% plotting angles
ax3=subplot(1,3,3);
hold(ax3,'on');
scatter(ax3,1.*ones(10,1),(theta1-mean(theta1)).*deg,'o','DisplayName','Static entrance','MarkerFaceColor','w');
scatter(ax3,2.*ones(10,1),(theta2-mean(theta2)).*deg,'s','DisplayName','Random entrance','MarkerFaceColor','w');
ax3.XLim = [0.5,2.5];
title(ax3,{'Dispersion of direction','at (x,y)=(4,3)'})
ylabel(ax3,{'Deviation from','mean vector (degrees)'},'FontSize',15,'FontWeight','bold');
ax3.XTick      = [1,2];
ax3.XTickLabel = {'Static','Random'};
ax3.Box='on';
ax3.Layer='top';

set([ax1,ax2,ax3],'FontName','CMU Sans Serif','FontSize',12);
ax1.Position(2) = 0.3;
ax2.Position(2) = 0.3;
ax3.Position(2) = 0.3;
ax1.Position(4) = 0.5;
ax2.Position(4) = 0.5;
ax3.Position(4) = 0.5;
ax3.Position(3) = ax3.Position(3)/2;
ax3.XAxis.FontSize          = 15;
ax3.XAxis.FontWeight        = 'bold';
ax3.XAxis.TickLabelRotation = 30;

colors_txt = lines(2);
text(ax3,0.8,0,sprintf('S.D.=%.2g^o',std(theta1)*deg),'HorizontalAlignment','center','VerticalAlignment','bottom','Color',colors_txt(1,:),'Rotation',90);
text(ax3,1.8,0,sprintf('S.D.=%.3g^o',std(theta2)*deg),'HorizontalAlignment','center','VerticalAlignment','bottom','Color',colors_txt(2,:),'Rotation',90);

if save_output_figures
    plot_func.saveFigure(fh,fullfile(outputDir,'example_angle_dev'),'png',true,{'Color','w','InvertHardcopy','off'},300);
end


%%


n_mice             = 8;
sd_thresh_values   = linspace(0,pi,100);
[p_values,P,Pf]    = func.pvalue_stddev_of_uniform_angle_less_than_S(sd_thresh_values,n_mice,[],[],[],true,true);

xtick_values       = 0:30:180;
xlim_values        = [0,185];

fh=figure('Position',[100,200,1000,400]);
ax2=axes('Position', [0.2743 0.3678 0.4232 0.3803],'FontSize',12,'Layer','top');

lcolor=lines(1);
ps                 = plot_func.getPlotStruct(Pf.s.*(180/pi), Pf.P, Pf.Pstd, 'S.D. of direction (degrees)', {'Probability','density, P(S.D.)'}, 'linear', 'linear', '', 0, false, '');
ax1=subplot(1,2,1);
errArgs    = {'Fill','on','Color','auto','LineWidth',0.1,'FaceAlpha',0.2};
plotArgs   = {};legendArgs = {};titleArgs  = {};
axisArgs   = {'FontSize',12,'Layer','top','Box','on','XLim',xlim_values,'XTick',xtick_values,'FontName','CMU Sans Serif'};
labelArgs  = {'XDisplacement',[0,0,0],'YDisplacement',[0,0,0],'FontSize',13};
[fh,ax1,lh] = plot_func.plotPlotStruct(ax1, ps, {'-'}, 1.5, 'n', lcolor, plotArgs, errArgs, axisArgs, legendArgs, labelArgs, titleArgs);

ax2=subplot(1,2,2);
plot(ax2,sd_thresh_values.*180./pi,p_values,'-s','MarkerFaceColor','w');
xlabel(ax2,'S.D. of direction (degrees)','FontSize',16);
ylabel(ax2,'p-value'                      ,'FontSize',18);
title( ax2,'Significance of the S.D. of direction','FontSize',12);
ax2.YScale   = 'log';
ax2.FontSize = 12;
ax2.XLim     = xlim_values;
ax2.XTick    = xtick_values;
ax2.YLim     = [1e-5,5];
ax2.YTick    = logspace(-5,0,6);
ax2.FontName = 'CMU Sans Serif';
plot_func.plotVerticalLines(  ax2,180,'LineStyle','--','LineWidth',1,'Color','k','HandleVisibility','off');
plot_func.plotHorizontalLines(ax2,  1,'LineStyle','--','LineWidth',1,'Color','k','HandleVisibility','off');

ax1.Position(2) = 0.2;
ax2.Position(2) = 0.2;
ax1.Position(4) = 0.4;
ax2.Position(4) = 0.4;
if save_output_figures
    plot_func.saveFigure(fh,fullfile(outputDir,sprintf('pvalue_of_SD_threshold')),'png',true,{'Color','w','InvertHardcopy','off'},300);
end
