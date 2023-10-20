clearvars
close all

set(0, 'defaulttextfontname', 'Arial')
set(0, 'defaultaxesfontname', 'Arial')

%mouse_dir_ft          = '../step_prob_matrices/fixed_target';
%mouse_dir_rt          = '../step_prob_matrices/relative_target';
%mouse_dir_l1          = '../step_prob_matrices/two_target_no_cues_tgt1_typical_mice';
%mouse_dir_l2          = '../step_prob_matrices/two_target_no_cues_tgt2_typical_mice';
%mouse_dir_p2          = '../step_prob_matrices/two_target_no_cues_probe2_A-B_typical_mice';
mouse_dir_ft_jk       = '../step_prob_matrices/fixed_target_jackknife';
mouse_dir_rt_jk       = '../step_prob_matrices/relative_target_jackknife';
mouse_dir_rt_180_jk   = '../step_prob_matrices/relative_target_R180_jackknife';
mouse_dir_l1_jk       = '../step_prob_matrices/two_target_no_cues_tgt1_jackknife_typical_mice';
mouse_dir_l2_jk       = '../step_prob_matrices/two_target_no_cues_tgt2_jackknife_typical_mice';
mouse_dir_p2_jk       = '../step_prob_matrices/two_target_no_cues_probe2_A-B_jackknife_typical_mice';
mouse_dir_p2_rot_jk   = '../step_prob_matrices/two_targets_rot_all_probe2_A-B_jackknife_typical_mice';
mouse_dir_ft          = mouse_dir_ft_jk;
mouse_dir_rt          = mouse_dir_rt_jk;
mouse_dir_l1          = mouse_dir_l1_jk;
mouse_dir_l2          = mouse_dir_l2_jk;
mouse_dir_p2          = mouse_dir_p2_jk;

outputDir    = '../figs/paper/step_prob_typical_mouse/jackknife';

if exist(outputDir,'dir') ~= 7
    mkdir(outputDir);
end

save_output_figures = false;

stddev_threshold         = 5; % degrees around the direction of the mean vector in each lattice site
p_value_stddev_threshold = func.pvalue_stddev_of_uniform_angle_less_than_S(stddev_threshold.*pi/180,8);
disp(   '***************');
disp(   '***************');
disp(   '***************');
disp(   '***************');
fprintf('*************** Chosen stddev threshold for plotting trajectories: S.D. = %g degrees\n',stddev_threshold);
disp(   '***************');
disp(   '***************');
fprintf('*************** Significance of chosen stddev threshold for plotting trajectories: p = %g\n',p_value_stddev_threshold);
disp(   '***************');
disp(   '***************');
disp(   '***************');
disp(   '***************');

use_grid_visits_as_color = false;
force_cumulative_prob    = false;
nPanel                   = 4;
mouse_idx                = [];
L                        = 11; % 51;
max_steps                = 4.*(L.^2-L); % max number of steps in the lattice, hence max total displacement

color_bg     = 'w';
color_get_fg = @(c1,c2) func.iif(strcmpi(color_bg,'k'),c1,c2);

% loading experimental data

input_files_ft          = fullfile(mouse_dir_ft         ,'independent/ntrials_14/stopfood/Pinit025',sprintf('stepmat_nose_L_%g_nstages_14_ntrials_14_Pinit_0.25_indept_stopfood_align_tgt.mat',L));
input_files_rt          = fullfile(mouse_dir_rt         ,'independent/ntrials_14/stopfood/Pinit025',sprintf('stepmat_nose_L_%g_nstages_14_ntrials_14_Pinit_0.25_indept_stopfood_align_ent.mat',L));
input_files_rt_R180     = fullfile(mouse_dir_rt_180_jk  ,'independent/ntrials_1/stopfood/Pinit025' ,sprintf('stepmat_nose_L_%g_nstages_1_ntrials_1_Pinit_0.25_indept_stopfood_align_ent.mat',  L));
input_files_l1          = fullfile(mouse_dir_l1         ,'independent/ntrials_18/stopfood/Pinit025',sprintf('stepmat_nose_L_%g_nstages_18_ntrials_18_Pinit_0.25_indept_stopfood_align_ent.mat',L));
input_files_l2          = fullfile(mouse_dir_l2         ,'independent/ntrials_8/stopfood/Pinit025' ,sprintf('stepmat_nose_L_%g_nstages_8_ntrials_8_Pinit_0.25_indept_stopfood_align_ent.mat',  L));
input_files_p2          = fullfile(mouse_dir_p2         ,'independent/ntrials_1/stopfood/Pinit025' ,sprintf('stepmat_nose_L_%g_nstages_1_ntrials_1_Pinit_0.25_indept_stopfood_align_ent.mat',  L));
input_files_p2_rot      = fullfile(mouse_dir_p2_rot_jk  ,'independent/ntrials_1/stopfood/Pinit025' ,sprintf('stepmat_nose_L_%g_nstages_1_ntrials_1_Pinit_0.25_indept_stopfood_align_ent.mat',  L));

input_files_ft_jk       = fullfile(mouse_dir_ft_jk      ,'independent/ntrials_14/stopfood/Pinit025',sprintf('stepmat_nose_L_%g_nstages_14_ntrials_14_Pinit_0.25_indept_stopfood_align_tgt_jackknife*.mat',L));
input_files_rt_jk       = fullfile(mouse_dir_rt_jk      ,'independent/ntrials_14/stopfood/Pinit025',sprintf('stepmat_nose_L_%g_nstages_14_ntrials_14_Pinit_0.25_indept_stopfood_align_ent_jackknife*.mat',L));
input_files_rt_R180_jk  = fullfile(mouse_dir_rt_180_jk  ,'independent/ntrials_1/stopfood/Pinit025' ,sprintf('stepmat_nose_L_%g_nstages_1_ntrials_1_Pinit_0.25_indept_stopfood_align_ent_jackknife*.mat',  L));
input_files_l1_jk       = fullfile(mouse_dir_l1_jk      ,'independent/ntrials_18/stopfood/Pinit025',sprintf('stepmat_nose_L_%g_nstages_18_ntrials_18_Pinit_0.25_indept_stopfood_align_ent_jackknife*.mat',L));
input_files_l2_jk       = fullfile(mouse_dir_l2_jk      ,'independent/ntrials_8/stopfood/Pinit025' ,sprintf('stepmat_nose_L_%g_nstages_8_ntrials_8_Pinit_0.25_indept_stopfood_align_ent_jackknife*.mat',  L));
input_files_p2_jk       = fullfile(mouse_dir_p2_jk      ,'independent/ntrials_1/stopfood/Pinit025' ,sprintf('stepmat_nose_L_%g_nstages_1_ntrials_1_Pinit_0.25_indept_stopfood_align_ent_jackknife*.mat',  L));
input_files_p2_rot_jk   = fullfile(mouse_dir_p2_rot_jk  ,'independent/ntrials_1/stopfood/Pinit025' ,sprintf('stepmat_nose_L_%g_nstages_1_ntrials_1_Pinit_0.25_indept_stopfood_align_ent_jackknife*.mat',  L));




% dr_target_correction       -> [dx,dy] (dx and dy are integer displacements in lattice coordinates)
%                               since the target hole can be at the boundary of a lattice site, its lattice coordinate may not be very precise
%                               thus, we may wish to correct the target by assuming x_target += dx and y_target += dy
d = load(input_files_ft);
dr_target_correction   = cellfun(@(x)func.inline_if(all(x==[6,6]),ones(1,2),zeros(1,2)),d.r_target_trial,'UniformOutput',false);

all_trials_ft          = import.import_mouse_stepmat(input_files_ft         ,'mouse',[],dr_target_correction);
all_trials_rt          = import.import_mouse_stepmat(input_files_rt         ,'mouse');
all_trials_rt_R180     = import.import_mouse_stepmat(input_files_rt_R180    ,'mouse');
all_trials_l1          = import.import_mouse_stepmat(input_files_l1         ,'mouse');%,[1,1]);
all_trials_l2          = import.import_mouse_stepmat(input_files_l2         ,'mouse');
all_trials_p2          = import.import_mouse_stepmat(input_files_p2         ,'mouse');
all_trials_p2_rot      = import.import_mouse_stepmat(input_files_p2_rot     ,'mouse');


all_trials_ft_jk       = import.import_mouse_stepmat(input_files_ft_jk      ,'mouse',[],dr_target_correction);
all_trials_rt_jk       = import.import_mouse_stepmat(input_files_rt_jk      ,'mouse');
all_trials_rt_R180_jk  = import.import_mouse_stepmat(input_files_rt_R180_jk ,'mouse');
all_trials_l1_jk       = import.import_mouse_stepmat(input_files_l1_jk      ,'mouse');%,[1,1]);
all_trials_l2_jk       = import.import_mouse_stepmat(input_files_l2_jk      ,'mouse');
all_trials_p2_jk       = import.import_mouse_stepmat(input_files_p2_jk      ,'mouse');
all_trials_p2_rot_jk   = import.import_mouse_stepmat(input_files_p2_rot_jk  ,'mouse');

disp(' ... ');
disp(' ... ');
disp(' ... ');
disp(' ... setting trial target to main target in all_trials_p2_rot');
all_trials_p2_rot.learning_stage.target = all_trials_p2_rot.simParam.food_site;
for k = 1:numel(all_trials_p2_rot_jk)
    all_trials_p2_rot_jk{k}.learning_stage.target = all_trials_p2_rot_jk{k}.simParam.food_site;
end
disp(' ... ');
disp(' ... ');
disp(' ... ');
disp('done loading data');

%%

fh=figure;
ax=axes('Position', [0.2743 0.3678 0.4232 0.3803],'FontSize',12,'Layer','top');
sd_thresh_values   = linspace(0,pi,100);
plot(ax,sd_thresh_values.*180./pi,func.pvalue_stddev_of_uniform_angle_less_than_S(sd_thresh_values,8),'-s','MarkerFaceColor','w');
xlabel(ax,'Direction deviation (degrees)','FontSize',16);
ylabel(ax,'p-value'                     ,'FontSize',18);
title( ax,'Significance of direction deviation','FontSize',12);
ax.YScale   = 'log';
ax.FontSize = 12;
ax.XTick    = [ax.XTick(1:(end-1)),180];
ax.XLim     = [0,185];
ax.XTick    = 0:30:180;
ax.YLim     = [1e-5,5];
ax.YTick    = logspace(-5,0,6);
plot_func.plotVerticalLines(  ax,180,'LineStyle',':','LineWidth',1,'Color','k','HandleVisibility','off');
plot_func.plotHorizontalLines(ax,  1,'LineStyle',':','LineWidth',1,'Color','k','HandleVisibility','off');
if save_output_figures
    plot_func.saveFigure(fh,fullfile(outputDir,sprintf('pvalue_of_SD_threshold_%gdeg',stddev_threshold)),'png',true,{'Color','w','InvertHardcopy','off'},300);
end

%% Random entrance experiments

show_jk_avg                 = true;
calc_significant_path_args  = {stddev_threshold*pi/180,'mean'};
use_color_quiver            = true;

fig_size           = [800,600];
gradient_cmap      = @plot_func.cmap_myjet;
quiverArgs         = {'Color',color_get_fg('w','k'),'LineWidth',1.5,'MaxHeadSize',10000,'Scale',1.1};
pcolorArgs         = {'FaceAlpha',0.6,'FaceColor','flat'};
startArgs          = {'LineWidth',2,'MarkerSize',8,'Color',color_get_fg('w','k'),'MarkerFaceColor',color_get_fg('k','w')};
targetArgs         = {'LineWidth',1,'Marker','o','Color',color_get_fg('w','k'),'MarkerSize',7,'MarkerFaceColor','r'};
arenaArgs          = {'LineWidth',1,'EdgeColor',color_get_fg('w','k')};
showLattice        = true;
latticeArgs        = {'EdgeColor',color_get_fg('w','k'),'EdgeAlpha',0.3};
show_holes         = false;
holesArgs          = {'MarkerSize',2,'Rotation',2.34459,'Color',0.8.*ones(1,3),'MarkerFaceColor','none'}; % angles in deg for each entrance: 42.973938964766596, -46.92147114856767, -136.01966864655256, 134.335072294753; in radians 0.7500367274862605, -0.8189341614220312, -2.3739910653540415, 2.344589312448054
showPreviousTarget = false;
prevTargetArgs     = {'LineWidth',1.5,'Marker','o','Color',[34,201,98]./255,'MarkerSize',5,'MarkerFaceColor',color_get_fg('w','k')};
outside_patch_args = {'FaceColor',color_get_fg('k','w'),'EdgeColor',color_get_fg('k','w')};
ind_trials         = [1,numel(all_trials_ft.learning_stage)];
ax1 = plot_func.plot_mouse_prob_gradient(all_trials_ft,ind_trials,[],mouse_idx,use_grid_visits_as_color,force_cumulative_prob,fig_size,gradient_cmap,...
                                         quiverArgs,pcolorArgs,startArgs,targetArgs,arenaArgs,...
                                         showLattice,latticeArgs,...
                                         showPreviousTarget,prevTargetArgs,[],outside_patch_args,...
                                         all_trials_ft_jk,show_jk_avg,calc_significant_path_args,use_color_quiver,...
                                         show_holes,holesArgs);


plot_func.set_point_label(ax1(1),'start'      ,'Start' ,'Color',color_get_fg('w','k')                                             ,'FontSize',10,'HorizontalAlignment','left','VerticalAlignment','bottom','Padding',[0.4,0]);
plot_func.set_point_label(ax1(2),'start'      ,'Start' ,'Color',color_get_fg('w','k')                                             ,'FontSize',10,'HorizontalAlignment','left','VerticalAlignment','bottom','Padding',[0.4,0]);
plot_func.set_point_label(ax1(1),'target'     ,'A'     ,'Color',func.getParamValue('MarkerFaceColor',targetArgs,    false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','left' ,'VerticalAlignment','top'   );
plot_func.set_point_label(ax1(2),'target'     ,'A'     ,'Color',func.getParamValue('MarkerFaceColor',targetArgs,    false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','right','VerticalAlignment','bottom','Padding',[-0.2,-0.2]);
%[th,lh1] = plot_func.set_point_label(ax1(1),'target_prev',sprintf('A_{trial %g}',all_trials_ft.learning_stage(ind_trials(1)).mouse(1).trial-1),'Color',func.getParamValue('Color',prevTargetArgs,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','left' ,'VerticalAlignment','top'   ,'BackgroundColor',[0.00,0.45,0.74,0.7]);
%[th,lh2] = plot_func.set_point_label(ax1(2),'target_prev',sprintf('A_{trial %g}',all_trials_ft.learning_stage(ind_trials(2)).mouse(1).trial-1),'Color',func.getParamValue('Color',prevTargetArgs,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','left' ,'VerticalAlignment','bottom','BackgroundColor',[0.00,0.45,0.74,0.7]);
%uistack(lh1,'top');
%uistack(lh2,'top');

ax1(1).Parent.Color = color_bg;
axis(ax1(1),'off');
axis(ax1(2),'off');
set(ax1(1).Title,'String',['Random, ',lower(ax1(1).Title.String)],'Color',color_get_fg('w','k'),'FontWeight','bold');
set(ax1(2).Title,'String',['Random, ',lower(ax1(2).Title.String)],'Color',color_get_fg('w','k'),'FontWeight','bold');

cbh = colorbar(ax1(2),'Position',[0.5134 0.4070 0.0129 0.0750],'Box','off','Color',color_get_fg('w','k'),'Orientation','vertical','Location','westoutside');
set(cbh      ,'Ticks',minmax(cbh.Ticks),'TickLabels',{'0','high'});
set(cbh.Title,'String',{'Step', 'prob.', 'grad.','(intensity)'},'Color',color_get_fg('w','k'));


displ_arrow_prop = {'LineWidth',3,'Color','m','MaxHeadSize',0.6,'DisplayName','TEV (vector sum of steps)'};
for i = 1:numel(ax1)
    
    % mouse estimate vector
    [mouse_estimate,v_unit,v_norm,v_norm_std,r0] = func.calc_mouse_estimate_vector(all_trials_ft.sites_per_stage{ind_trials(i)},all_trials_ft.simParam,10,false);    
    
    % calculating mouse estimate direction stddev
    mouse_estimate_jk     = func.calc_mouse_estimate_vector(import.get_sites_for_learning_stage(all_trials_ft_jk,ind_trials(i)),all_trials_ft_jk{1}.simParam,0,false);
    mouse_estimate_jk_std = func.angle_stddev(cell2mat(mouse_estimate_jk'),'mean');
    theta_mouse_estimate  = atan2(mouse_estimate(2),mouse_estimate(1));
    
    % plotting
    plot_func.myplotv(mouse_estimate,r0,ax1(i),'HandleVisibility','off',displ_arrow_prop{:});
    plot_func.circle_sector(ax1(i),r0,vecnorm(mouse_estimate),theta_mouse_estimate+mouse_estimate_jk_std.*[-1/2,1/2],'m',100,'FaceAlpha',0.25,'HandleVisibility','off');
end

ax_temp=axes;
%plot_func.myplotv(NaN(1,2),[],ax_temp,displ_arrow_prop{:});
plot_func.myplotv([-999,-999],[-990,-990],ax_temp,displ_arrow_prop{:});
set(ax_temp,'XLim',[0,1],'YLim',[0,1]);
legend(ax_temp,'Box','off','Color','k','TextColor',color_get_fg('w','k'));
axis(ax_temp,'off');




if save_output_figures
    plot_func.saveFigure(ax1(1).Parent,fullfile(outputDir,sprintf('grad_map_random_entrance_%gdeg',stddev_threshold)),'png',true,{'Color',color_bg,'InvertHardcopy','off'},300);
end

%% Static entrance experiments

show_jk_avg                 = true;
calc_significant_path_args  = {stddev_threshold*pi/180,'mean'};
use_color_quiver            = true;

fig_size           = [800,600];
gradient_cmap      = @plot_func.cmap_myjet;
quiverArgs         = {'Color',color_get_fg('w','k'),'LineWidth',1.5,'MaxHeadSize',10000,'Scale',1.1};
pcolorArgs         = {'FaceAlpha',0.6,'FaceColor','flat'};
startArgs          = {'LineWidth',2,'MarkerSize',8,'Color',color_get_fg('w','k'),'MarkerFaceColor',color_get_fg('k','w')};
targetArgs         = {'LineWidth',1,'Marker','o','Color',color_get_fg('w','k'),'MarkerSize',7,'MarkerFaceColor','r'};
arenaArgs          = {'LineWidth',1,'EdgeColor',color_get_fg('w','k')};
showLattice        = true;
latticeArgs        = {'EdgeColor',color_get_fg('w','k'),'EdgeAlpha',0.3};
showPreviousTarget = false;
prevTargetArgs     = {'LineWidth',3,'Marker','o','Color',[34,201,98]./255,'MarkerSize',5};
outside_patch_args = {'FaceColor',color_get_fg('k','w'),'EdgeColor',color_get_fg('k','w')};
ind_trials         = [1,numel(all_trials_rt.learning_stage)];
ax1 = plot_func.plot_mouse_prob_gradient(all_trials_rt,ind_trials,[],mouse_idx,use_grid_visits_as_color,force_cumulative_prob,fig_size,gradient_cmap,...
                                         quiverArgs,pcolorArgs,startArgs,targetArgs,arenaArgs,...
                                         showLattice,latticeArgs,...
                                         showPreviousTarget,prevTargetArgs,[],outside_patch_args,...
                                         all_trials_rt_jk,show_jk_avg,calc_significant_path_args,use_color_quiver);


plot_func.set_point_label(ax1(1),'start' ,'Start','Color',color_get_fg('w','k')                                         ,'FontSize',10,'HorizontalAlignment','left','VerticalAlignment','bottom','Padding',[0.4,0]);
plot_func.set_point_label(ax1(2),'start' ,'Start','Color',color_get_fg('w','k')                                         ,'FontSize',10,'HorizontalAlignment','left','VerticalAlignment','bottom','Padding',[0.4,0]);
plot_func.set_point_label(ax1(1),'target','A'    ,'Color',func.getParamValue('MarkerFaceColor',targetArgs,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','right','VerticalAlignment','top');
plot_func.set_point_label(ax1(2),'target','A'    ,'Color',func.getParamValue('MarkerFaceColor',targetArgs,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','right','VerticalAlignment','top','Padding',[-0.4,-0.2],'BackgroundColor',[1,1,1,0.0]);


ax1(1).Parent.Color = color_bg;
axis(ax1(1),'off');
axis(ax1(2),'off');
set(ax1(1).Title,'String',['Static, ',lower(ax1(1).Title.String)],'Color',color_get_fg('w','k'),'FontWeight','bold');
set(ax1(2).Title,'String',['Static, ',lower(ax1(2).Title.String)],'Color',color_get_fg('w','k'),'FontWeight','bold');

cbh = colorbar(ax1(2),'Position',[0.5134 0.4070 0.0129 0.0750],'Box','off','Color',color_get_fg('w','k'),'Orientation','vertical','Location','westoutside');
set(cbh      ,'Ticks',minmax(cbh.Ticks),'TickLabels',{'0','high'});
set(cbh.Title,'String',{'Step', 'prob.', 'grad.','(intensity)'},'Color',color_get_fg('w','k'));


rescale_to_target = [false,true];
displ_arrow_prop   = {'LineWidth',3,'Color','m','MaxHeadSize',0.6,'DisplayName','TEV (vector sum of steps)'};
maxheadsize_values = [0.6,0.35];
for i = 1:numel(ax1)
    
    % mouse estimate vector
    [mouse_estimate,v_unit,v_norm,v_norm_std,r0] = func.calc_mouse_estimate_vector(all_trials_rt.sites_per_stage{ind_trials(i)},all_trials_rt.simParam,10,rescale_to_target(i));
    
    % calculating mouse estimate direction stddev
    mouse_estimate_jk     = func.calc_mouse_estimate_vector(import.get_sites_for_learning_stage(all_trials_rt_jk,ind_trials(i)),all_trials_rt_jk{1}.simParam,0,false);
    mouse_estimate_jk_std = func.angle_stddev(cell2mat(mouse_estimate_jk'),'mean');
    theta_mouse_estimate  = atan2(mouse_estimate(2),mouse_estimate(1));
    
    %[Gm_xlim,Gm_ylim] = plot_func.get_square_boundary(r_start,mouse_estimate.*max_steps/100);
    %ph = plot_func.plot_square(ax1(i),Gm_xlim,Gm_ylim,1,'r','LineWidth',2,'FaceColor','none');
    displ_arrow_prop = func.set_arg_in_cellarray(displ_arrow_prop,'MaxHeadSize',maxheadsize_values(i));
    plot_func.myplotv(mouse_estimate,r0,ax1(i),'HandleVisibility','off',displ_arrow_prop{:});
    plot_func.circle_sector(ax1(i),r0,vecnorm(mouse_estimate),theta_mouse_estimate+mouse_estimate_jk_std.*[-1/2,1/2],'m',100,'FaceAlpha',0.25,'HandleVisibility','off');
end


ax_temp=axes;
%plot_func.myplotv(NaN(1,2),[],ax_temp,displ_arrow_prop{:});
plot_func.myplotv([-999,-999],[-990,-990],ax_temp,displ_arrow_prop{:});
set(ax_temp,'XLim',[0,1],'YLim',[0,1]);
legend(ax_temp,'Box','off','Color','k','TextColor',color_get_fg('w','k'));
axis(ax_temp,'off');


% panel_labels = 'ab';
% for k = 1:numel(ax1)
%     text(ax1(k),ax1(k).XLim(1),ax1(k).YLim(1),[panel_labels(k),'.'],'Color',color_get_fg('w','k'),'FontWeight','bold','FontSize',22,'HorizontalAlignment','left','VerticalAlignment','top');
% end

if save_output_figures
    plot_func.saveFigure(ax1(1).Parent,fullfile(outputDir,sprintf('grad_map_static_entrance_%gdeg',stddev_threshold)),'png',true,{'Color',color_bg,'InvertHardcopy','off'},300);
end




%% Static vs. random entrance experiments -- step angle deviation plot

color_rt = [  65, 102, 216 ]./255;
color_ft = [ 224,  53,  53 ]./255;

% calculating target estimate versus trials
v_tgt_estimate_rt       = func.calc_mouse_estimate_all_stages(all_trials_rt.learning_stage,all_trials_rt.simParam);
v_tgt_rt                = func.calc_target_vector(all_trials_rt.simParam);
cos_theta_dev_rt        =         arrayfun(@(trial) func.angle_between_vectors(trial.v_unit,v_tgt_rt,[],true)    , v_tgt_estimate_rt  , 'UniformOutput', false);
theta_dev_avg_rt        =          cellfun(@(trial) func.avg_angle_from_cos(trial,true,'avg')                    , cos_theta_dev_rt   );
theta_dev_std_rt        =          cellfun(@(trial) func.avg_angle_from_cos(trial,true,'std')                    , cos_theta_dev_rt   );
theta_dev_err_rt        =          cellfun(@(trial) func.avg_angle_from_cos(trial,true,'err')                    , cos_theta_dev_rt   );
theta_dev_minmax_rt     = cell2mat(cellfun(@(trial) func.avg_angle_from_cos(trial,true,'minmax')                 , cos_theta_dev_rt   , 'UniformOutput',false))';
theta_dev_std_jk_rt     =          cellfun(@(trial) jackknife(@(tr)func.avg_angle_from_cos(tr,true,'std'),trial) , cos_theta_dev_rt   , 'UniformOutput',false );
theta_dev_std_err_rt    =          cellfun(@(trial) std(trial)./sqrt(numel(trial))                               , theta_dev_std_jk_rt);
theta_dev_std_minmax_rt = cell2mat(cellfun(@(trial) minmax(reshape(trial,1,[]))                                  , theta_dev_std_jk_rt, 'UniformOutput', false))';


v_tgt_estimate_ft   = func.calc_mouse_estimate_all_stages(all_trials_ft.learning_stage,all_trials_ft.simParam);
v_tgt_ft                = cell2mat(arrayfun(@(tgt_site)func.calc_target_vector(all_trials_ft.simParam,tgt_site)      , [all_trials_ft.learning_stage(:).target]          , 'UniformOutput',false)');
cos_theta_dev_ft        =          arrayfun(@(trial,k) func.angle_between_vectors(trial.v_unit,v_tgt_ft(k,:),[],true), v_tgt_estimate_ft  , (1:numel(v_tgt_estimate_ft))', 'UniformOutput', false);
theta_dev_avg_ft        =           cellfun(@(trial)   func.avg_angle_from_cos(trial,true,'avg')                     , cos_theta_dev_ft   );
theta_dev_std_ft        =           cellfun(@(trial)   func.avg_angle_from_cos(trial,true,'std')                     , cos_theta_dev_ft   );
theta_dev_err_ft        =           cellfun(@(trial)   func.avg_angle_from_cos(trial,true,'err')                     , cos_theta_dev_ft   );
theta_dev_minmax_ft     = cell2mat( cellfun(@(trial)   func.avg_angle_from_cos(trial,true,'minmax')                  , cos_theta_dev_ft   , 'UniformOutput',false))';
theta_dev_std_jk_ft     =           cellfun(@(trial) jackknife(@(tr)func.avg_angle_from_cos(tr,true,'std'),trial)    , cos_theta_dev_ft   , 'UniformOutput',false );
theta_dev_std_err_ft    =           cellfun(@(trial) std(trial)./sqrt(numel(trial))                                  , theta_dev_std_jk_ft);
theta_dev_std_minmax_ft = cell2mat( cellfun(@(trial) minmax(reshape(trial,1,[]))                                     , theta_dev_std_jk_ft, 'UniformOutput', false))';

trial_num           = 1:numel(v_tgt_estimate_rt);

% t-test of the same trial in condition rt vs ft
tt_rtft  = cellfun(@(trial_ft,trial_rt) ttest.ttest2Struct(acos(trial_ft),acos(trial_rt)), cos_theta_dev_ft, cos_theta_dev_rt);
% t-test of the same condition in 1st vs. last trial
tt_rt    = ttest.ttest2Struct(acos(cos_theta_dev_rt{1}),acos(cos_theta_dev_rt{14}));
tt_ft    = ttest.ttest2Struct(acos(cos_theta_dev_ft{1}),acos(cos_theta_dev_ft{14}));

tt_pcutoff=0.05;

fprintf('*** TEV-target deviation\n');
fprintf('-\n');
fprintf('*** Trial values\n');
fprintf('     Static entrance (1 vs. 14)\n');
fprintf('          first trial: m+-SD = %.8g +- %.8g deg\n',theta_dev_avg_rt( 1),theta_dev_std_rt( 1));
fprintf('           last trial: m+-SD = %.8g +- %.8g deg\n',theta_dev_avg_rt(14),theta_dev_std_rt(14));
fprintf('     Random entrance (1 vs. 14)\n');
fprintf('          first trial: m+-SD = %.8g +- %.8g deg\n',theta_dev_avg_ft( 1),theta_dev_std_ft( 1));
fprintf('           last trial: m+-SD = %.8g +- %.8g deg\n',theta_dev_avg_ft(14),theta_dev_std_ft(14));
fprintf('-\n');
fprintf('*** T-Test between first and last trials\n');
fprintf('     Static entrance (1 vs. 14)%s:: T = %.8g     p = %.8g\n',func.iif(tt_rt.p<tt_pcutoff,'(*)','   '),tt_rt.t,tt_rt.p);
fprintf('     Random entrance (1 vs. 14)%s:: T = %.8g     p = %.8g\n',func.iif(tt_ft.p<tt_pcutoff,'(*)','   '),tt_ft.t,tt_ft.p);


fig                 = figure;%('Units','inches');fig.Position(3:4) = FIGSIZE_1PANEL_in;
ax                  = axes('Position',[0.1414 0.2548 0.3789 0.3712]);% AX_POS_1PANEL);%
hold(ax,'on');

plot_func.fill_between_lines_Y(ax, trial_num, theta_dev_minmax_ft(1,:), theta_dev_minmax_ft(2,:), color_ft, 'FaceAlpha', 0.15, 'EdgeColor', 'none');
plot_func.fill_between_lines_Y(ax, trial_num, theta_dev_minmax_rt(1,:), theta_dev_minmax_rt(2,:), color_rt, 'FaceAlpha', 0.15, 'EdgeColor', 'none');
errorbar(ax, trial_num, theta_dev_avg_ft, theta_dev_err_ft, ':s', 'Color', color_ft, 'MarkerFaceColor','w','HandleVisibility','on','CapSize',0,'MarkerSize',7,'LineWidth',1,'DisplayName','Random');
errorbar(ax, trial_num, theta_dev_avg_rt, theta_dev_err_rt, ':o', 'Color', color_rt, 'MarkerFaceColor','w','HandleVisibility','on','CapSize',0,'MarkerSize',6,'LineWidth',1,'DisplayName','Static');
plot(ax, trial_num([tt_rtft.hFDR]), 170.*ones(size(find([tt_rtft.hFDR]))), '*k', 'MarkerSize',5,'HandleVisibility','off')
plot_func.plotHorizontalLines(ax,0,'XMin',0,'XMax',15,'Color','k','LineStyle',':','LineWidth',1,'HandleVisibility','off');
plot_func.annotate_ttest_data(ax,trial_num(1),trial_num(end),-10,8,1.5,'','p',[],{'Color',color_rt,'MarkerFaceColor',color_rt,'HandleVisibility','off'},{'Color',color_rt,'LineWidth',1.5,'HandleVisibility','off'});
set(ax,'XLim',[0,15],'YLim',[-35,180],'XTick',trial_num(2:2:15),'YTick',-30:30:180,'TickDir','out','TickLength',[0.015,ax.TickLength(2)]);
xlabel(ax,'Trial'                                            ,'FontSize',11);
ylabel(ax,'\textsf{\textbf{TEV-Target deviation ($^\circ$)}}','FontSize',12,'Interpreter','latex');
legend(ax,'Position',[0.1674 0.6291 0.3050 0.0400],'Box','off','NumColumns',2,'FontSize',10);

axSD = axes('Position', [0.1414 0.6852 0.3789 0.1219]);
hold(axSD,'on');
plot_func.fill_between_lines_Y(axSD, trial_num, theta_dev_std_minmax_ft(1,:), theta_dev_std_minmax_ft(2,:), color_ft, 'FaceAlpha', 0.15, 'EdgeColor', 'none');
plot_func.fill_between_lines_Y(axSD, trial_num, theta_dev_std_minmax_rt(1,:), theta_dev_std_minmax_rt(2,:), color_rt, 'FaceAlpha', 0.15, 'EdgeColor', 'none');
errorbar(axSD, trial_num, theta_dev_std_ft, theta_dev_std_err_ft, ':s', 'Color', color_ft, 'MarkerFaceColor','w','HandleVisibility','off','CapSize',0,'MarkerSize',7,'LineWidth',1);
errorbar(axSD, trial_num, theta_dev_std_rt, theta_dev_std_err_rt, ':o', 'Color', color_rt, 'MarkerFaceColor','w','HandleVisibility','off','CapSize',0,'MarkerSize',6,'LineWidth',1);
plot_func.plotHorizontalLines(axSD,[0,45,90],'XMin',0,'XMax',15,'Color','k','LineStyle',':','LineWidth',1,'HandleVisibility','off');
set(axSD,'XLim',[0,15],'YLim', [-20,130],'XTick',trial_num(2:2:15),'YTick',0:45:90,'XTickLabel',{},'TickDir','out','TickLength',[0.015,ax.TickLength(2)]);
ylabel(axSD,'\textsf{\textbf{S.D. ($^\circ$)}}','FontSize',10,'Interpreter','latex');
title(axSD,'Static vs. Random','FontSize',14,'FontName','Arial');

fig2 = figure;
ax2  = axes;
plot(ax2,acos(cell2mat(cos_theta_dev_rt'))'.*180/pi,'LineWidth',2);
legend(ax2,arrayfun(@(n) sprintf('mouse %d',n),v_tgt_estimate_rt(1).mouse_id,'UniformOutput',false)')
xlabel(ax2,'Trial'                                            ,'FontSize',11);
ylabel(ax2,'\textsf{\textbf{TEV-Target deviation ($^\circ$)}}','FontSize',12,'Interpreter','latex');
title(ax2,'Static target condition','FontSize',14);

if save_output_figures
    plot_func.saveFigure([fig,fig2],fullfile(outputDir,{'TEV_target_deviation_vs_trials','TEV_target_deviation_vs_trials_STATIC_tgt'}),'png',true,{'Color','w','InvertHardcopy','off'},300);
end



%% Static entrance -- Probe R180

show_jk_avg                 = true;
calc_significant_path_args  = {stddev_threshold*pi/180,'mean'};
use_color_quiver            = true;

fig_size           = [500,350];
gradient_cmap      = @plot_func.cmap_myjet;
quiverArgs         = {'Color',color_get_fg('w','k'),'LineWidth',1.5,'MaxHeadSize',10000,'Scale',1.1};
pcolorArgs         = {'FaceAlpha',0.6};
startRELArgs       = {'LineWidth',2,'MarkerSize',8,'Color',color_get_fg('w','k'),'Marker','s','MarkerFaceColor',color_get_fg('k','w')};
startArgs          = {'LineWidth',2,'MarkerSize',7,'Color',0.6.*ones(1,3),'Marker','d','Padding',[0,0.5],'MarkerFaceColor',color_get_fg('k','w'),'DisplayName','startT'};
targetArgs         = {'LineWidth',1.5,'Marker','o','Color','r','MarkerSize',7,'MarkerFaceColor',color_get_fg('k','w'),'DisplayName','targetA'};
targetArgsREL      = {'LineWidth',2,'Marker','^','Color',[155, 112, 83]./255,'MarkerSize',8,'MarkerFaceColor',color_get_fg('k','w')};
arenaArgs          = {'LineWidth',1,'EdgeColor',color_get_fg('w','k')};
showLattice        = true;
latticeArgs        = {'EdgeColor',color_get_fg('w','k'),'EdgeAlpha',0.3};
showPreviousTarget = false;
prevTargetArgs     = {'LineWidth',3,'Marker','o','Color',[34,201,98]./255,'MarkerSize',5};
outside_patch_args = {'FaceColor',color_get_fg('k','w'),'EdgeColor',color_get_fg('k','w')};
ind_trials         = 1;
ax1 = plot_func.plot_mouse_prob_gradient(all_trials_rt_R180,ind_trials,[],mouse_idx,use_grid_visits_as_color,force_cumulative_prob,fig_size,gradient_cmap,...
                                         quiverArgs,pcolorArgs,startRELArgs,targetArgsREL,arenaArgs,...
                                         showLattice,latticeArgs,...
                                         showPreviousTarget,prevTargetArgs,[],outside_patch_args,...
                                         all_trials_rt_R180_jk,show_jk_avg,calc_significant_path_args,use_color_quiver);

start_pos = arena.get_start_position(arena.rotate_start_label(all_trials_rt_R180.simParam.start_pos,pi),all_trials_rt_R180.simParam.shape,all_trials_rt_R180.simParam.L);
startAh1  = plot_func.plot_lattice_site(ax1,all_trials_rt_R180.simParam.L,start_pos,startArgs{:});
tgtAh1    = plot_func.plot_lattice_site(ax1,all_trials_rt_R180.simParam.L,all_trials_rt_R180.simParam.food_site,targetArgs{:});
[~,~  ]   = plot_func.set_point_label(ax1,'start'  ,'Start'             ,'Color',color_get_fg('w','k')                                         ,'FontSize',10,'HorizontalAlignment','left','VerticalAlignment','top'   ,'Padding',[-0.3,0]);
[~,~  ]   = plot_func.set_point_label(ax1,'startT' ,'Start on Training' ,'Color',func.getParamValue('Color',startArgs    ,false)               ,'FontSize',10,'HorizontalAlignment','left','VerticalAlignment','bottom','Padding',[-0.3,0]);
[~,lh1]   = plot_func.set_point_label(ax1,'target' ,'REL A'             ,'Color',func.getParamValue('Color',targetArgsREL,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','left' ,'VerticalAlignment','bottom','Padding',[ -0.1, 0.1],'BackgroundColor',[1,1,1,0.0]);
[~,~  ]   = plot_func.set_point_label(ax1,'targetA','A'                 ,'Color',func.getParamValue('Color',targetArgs   ,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','left' ,'VerticalAlignment','bottom','Padding',[ -0.1, 0.1],'BackgroundColor',[1,1,1,0.0]);
uistack(lh1   ,'top');
uistack(tgtAh1,'top');

ax1.Parent.Color = color_bg;
axis(ax1,'off');
set(ax1(1).Title,'String','Static entrance Probe 180^o','Color',color_get_fg('w','k'),'FontWeight','bold');

cbh = colorbar(ax1,'Position',[0.1460 0.3571 0.0203 0.1111],'Box','off','Color',color_get_fg('w','k'),'Orientation','vertical','Location','westoutside');
set(cbh      ,'Ticks',minmax(cbh.Ticks),'TickLabels',{'0','high'});
set(cbh.Title,'String',{'Step', 'prob.', 'grad.','(intensity)'},'Color',color_get_fg('w','k'));

ax1.XDir = 'reverse';
ax1.YDir = 'normal';

rescale_to_target  = true;
displ_arrow_prop   = {'LineWidth',3,'Color','m','MaxHeadSize',0.6,'DisplayName','TEV (vector sum of steps)'};
maxheadsize_values = 0.35;
i=1;

% mouse estimate vector
start_REL_site  = arena.get_start_position(all_trials_rt_R180.simParam.start_pos,all_trials_rt_R180.simParam.shape,all_trials_rt_R180.simParam.L);
target_REL_site = all_trials_rt_R180.learning_stage(1).target;
[mouse_estimate,v_unit,v_norm,v_norm_std,r0] = func.calc_mouse_estimate_vector(all_trials_rt_R180.sites_per_stage{ind_trials(i)},all_trials_rt_R180.simParam,10,rescale_to_target(i),start_REL_site,target_REL_site);

% calculating mouse estimate direction stddev
mouse_estimate_jk     = func.calc_mouse_estimate_vector(import.get_sites_for_learning_stage(all_trials_rt_R180_jk,ind_trials(i)),all_trials_rt_R180_jk{1}.simParam,0,false);
mouse_estimate_jk_std = func.angle_stddev(cell2mat(mouse_estimate_jk'),'mean');
theta_mouse_estimate  = atan2(mouse_estimate(2),mouse_estimate(1));

%[Gm_xlim,Gm_ylim] = plot_func.get_square_boundary(r_start,mouse_estimate.*max_steps/100);
%ph = plot_func.plot_square(ax1(i),Gm_xlim,Gm_ylim,1,'r','LineWidth',2,'FaceColor','none');
displ_arrow_prop = func.set_arg_in_cellarray(displ_arrow_prop,'MaxHeadSize',maxheadsize_values(i));
plot_func.myplotv(mouse_estimate,r0,ax1(i),'HandleVisibility','off',displ_arrow_prop{:});
plot_func.circle_sector(ax1(i),r0,vecnorm(mouse_estimate),theta_mouse_estimate+mouse_estimate_jk_std.*[-1/2,1/2],'m',100,'FaceAlpha',0.25,'HandleVisibility','off');



ax_temp=axes;
%plot_func.myplotv(NaN(1,2),[],ax_temp,displ_arrow_prop{:});
plot_func.myplotv([-999,-999],[-990,-990],ax_temp,displ_arrow_prop{:});
set(ax_temp,'XLim',[0,1],'YLim',[0,1]);
legend(ax_temp,'Box','off','Color','k','TextColor',color_get_fg('w','k'),'Position', [0.0521 0.0555 0.3804 0.0503]);
axis(ax_temp,'off');

if save_output_figures
    plot_func.saveFigure(ax1(1).Parent,fullfile(outputDir,sprintf('grad_map_static_entrance_%gdeg_R180_REL_PROBE',stddev_threshold)),'png',true,{'Color',color_bg,'InvertHardcopy','off'},300);
end



%% 2-targets -- target A

show_jk_avg                 = true;
calc_significant_path_args  = {stddev_threshold*pi/180,'mean'};
use_color_quiver            = true;

fig_size           = [800,600];
gradient_cmap      = @plot_func.cmap_myjet;
quiverArgs         = {'Color',color_get_fg('w','k'),'LineWidth',1.5,'MaxHeadSize',10000,'Scale',1.1};
pcolorArgs         = {'FaceAlpha',0.6};
startArgs          = {'LineWidth',2,'MarkerSize',8,'Color',color_get_fg('w','k'),'MarkerFaceColor',color_get_fg('k','w')};
%targetArgsA        = {'LineWidth',1.5,'Marker','o','Color','r','MarkerSize',5,'MarkerFaceColor',color_get_fg('w','k')};
targetArgsA        = {'LineWidth',1,'Marker','o','Color',color_get_fg('w','k'),'MarkerSize',7,'MarkerFaceColor','r'};
%targetArgsB        = {'LineWidth',1.5,'Marker','o','Color','b','MarkerSize',5,'MarkerFaceColor',color_get_fg('k','w'),'DisplayName','targetB'};
arenaArgs          = {'LineWidth',1,'EdgeColor',color_get_fg('w','k')};
showLattice        = true;
latticeArgs        = {'EdgeColor',color_get_fg('w','k'),'EdgeAlpha',0.3};
showPreviousTarget = false;
prevTargetArgs     = {'LineWidth',3,'Marker','o','Color',[34,201,98]./255,'MarkerSize',5};
outside_patch_args = {'FaceColor',color_get_fg('k','w'),'EdgeColor',color_get_fg('k','w')};
ind_trials         = [1,16];%[1,numel(all_trials_l1.learning_stage)];
ax1 = plot_func.plot_mouse_prob_gradient(all_trials_l1,ind_trials,[],mouse_idx,use_grid_visits_as_color,force_cumulative_prob,fig_size,gradient_cmap,...
                                         quiverArgs,pcolorArgs,startArgs,targetArgsA,arenaArgs,...
                                         showLattice,latticeArgs,...
                                         showPreviousTarget,prevTargetArgs,[],outside_patch_args,...
                                         all_trials_l1_jk,show_jk_avg,calc_significant_path_args,use_color_quiver);

%tgtBh1    = plot_func.plot_lattice_site(ax1(1),all_trials_l1.simParam.L,all_trials_l2.simParam.food_site,targetArgsB{:});
%tgtBh2    = plot_func.plot_lattice_site(ax1(2),all_trials_l1.simParam.L,all_trials_l2.simParam.food_site,targetArgsB{:});
plot_func.set_point_label(ax1(1),'start'  ,'Start','Color',color_get_fg('w','k')                                          ,'FontSize',10,'HorizontalAlignment','left','VerticalAlignment','bottom','Padding',[0.4,0]);
plot_func.set_point_label(ax1(2),'start'  ,'Start','Color',color_get_fg('w','k')                                          ,'FontSize',10,'HorizontalAlignment','left','VerticalAlignment','bottom','Padding',[0.4,0]);
plot_func.set_point_label(ax1(1),'target' ,'A'    ,'Color',func.getParamValue('MarkerFaceColor',targetArgsA,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','left' ,'VerticalAlignment','bottom','Padding',[+0.4,+0.2]);
plot_func.set_point_label(ax1(2),'target' ,'A'    ,'Color',func.getParamValue('MarkerFaceColor',targetArgsA,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','right','VerticalAlignment','top'   ,'Padding',[-0.1,+0.2],'BackgroundColor',[1,1,1,0.0]);
%[th,~  ]  = plot_func.set_point_label(ax1(1),'targetB','B'    ,'Color',func.getParamValue('Color',targetArgsB,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','left' ,'VerticalAlignment','bottom','Padding',[ 0.0, 0.0],'BackgroundColor',[1,1,1,0.5]);
%[th,~  ]  = plot_func.set_point_label(ax1(2),'targetB','B'    ,'Color',func.getParamValue('Color',targetArgsB,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','left' ,'VerticalAlignment','bottom','Padding',[ 0.0, 0.0],'BackgroundColor',[1,1,1,0.5]);
%uistack(tgtBh1,'top');
%uistack(tgtBh2,'top');

ax1(1).Parent.Color = color_bg;
axis(ax1(1),'off');
axis(ax1(2),'off');
set(ax1(1).Title,'String',['2-targets, ',lower(ax1(1).Title.String),'-A'],'Color',color_get_fg('w','k'),'FontWeight','bold');
set(ax1(2).Title,'String',['2-targets, ',lower(ax1(2).Title.String),'-A'],'Color',color_get_fg('w','k'),'FontWeight','bold');

cbh = colorbar(ax1(2),'Position',[0.5134 0.4070 0.0129 0.0750],'Box','off','Color',color_get_fg('w','k'),'Orientation','vertical','Location','westoutside');
set(cbh      ,'Ticks',minmax(cbh.Ticks),'TickLabels',{'0','high'});
set(cbh.Title,'String',{'Step', 'prob.', 'grad.','(intensity)'},'Color',color_get_fg('w','k'));


rescale_to_target = [false,true];
displ_arrow_prop  = {'LineWidth',3,'Color','m','MaxHeadSize',0.6,'DisplayName','TEV (vector sum of steps)'};
maxheadsize_values = [0.6,0.4];
for i = 1:numel(ax1)
    % mouse estimate vector
    [mouse_estimate,v_unit,v_norm,v_norm_std,r0] = func.calc_mouse_estimate_vector(all_trials_l1.sites_per_stage{ind_trials(i)},all_trials_l1.simParam,10,rescale_to_target(i));
    
    % calculating mouse estimate direction stddev
    mouse_estimate_jk     = func.calc_mouse_estimate_vector(import.get_sites_for_learning_stage(all_trials_l1_jk,ind_trials(i)),all_trials_l1_jk{1}.simParam,0,false);
    mouse_estimate_jk_std = func.angle_stddev(cell2mat(mouse_estimate_jk'),'mean');
    theta_mouse_estimate  = atan2(mouse_estimate(2),mouse_estimate(1));
    
    displ_arrow_prop = func.set_arg_in_cellarray(displ_arrow_prop,'MaxHeadSize',maxheadsize_values(i));
    plot_func.myplotv(mouse_estimate,r0,ax1(i),'HandleVisibility','off',displ_arrow_prop{:});
    plot_func.circle_sector(ax1(i),r0,vecnorm(mouse_estimate),theta_mouse_estimate+mouse_estimate_jk_std.*[-1/2,1/2],'m',100,'FaceAlpha',0.25,'HandleVisibility','off');
end


ax_temp=axes;
%plot_func.myplotv(NaN(1,2),[],ax_temp,displ_arrow_prop{:});
plot_func.myplotv([-999,-999],[-990,-990],ax_temp,displ_arrow_prop{:});
set(ax_temp,'XLim',[0,1],'YLim',[0,1]);
legend(ax_temp,'Box','off','Color','k','TextColor',color_get_fg('w','k'));
axis(ax_temp,'off');


% panel_labels = 'ab';
% for k = 1:numel(ax1)
%     text(ax1(k),ax1(k).XLim(1),ax1(k).YLim(1),[panel_labels(k),'.'],'Color',color_get_fg('w','k'),'FontWeight','bold','FontSize',22,'HorizontalAlignment','left','VerticalAlignment','top');
% end

if save_output_figures
    plot_func.saveFigure(ax1(1).Parent,fullfile(outputDir,sprintf('grad_map_2targets_tgt-A_%gdeg',stddev_threshold)),'png',true,{'Color',color_bg,'InvertHardcopy','off'},300);
end




%% 2-targets -- target B

show_jk_avg                 = true;
calc_significant_path_args  = {stddev_threshold*pi/180,'mean'};
use_color_quiver            = true;

fig_size           = [800,600];
gradient_cmap      = @plot_func.cmap_myjet;
quiverArgs         = {'Color',color_get_fg('w','k'),'LineWidth',1.5,'MaxHeadSize',10000,'Scale',1.1};
pcolorArgs         = {'FaceAlpha',0.6};
startArgs          = {'LineWidth',2,'MarkerSize',8,'Color',color_get_fg('w','k'),'MarkerFaceColor',color_get_fg('k','w')};
targetArgsA        = {'LineWidth',1.5,'Marker','o','Color','r','MarkerSize',7,'MarkerFaceColor',color_get_fg('k','w'),'DisplayName','targetA'};
%targetArgsB        = {'LineWidth',1.5,'Marker','o','Color','b','MarkerSize',5,'MarkerFaceColor',color_get_fg('w','k')};
targetArgsB        = {'LineWidth',1,'Marker','o','Color',color_get_fg('w','k'),'MarkerSize',7,'MarkerFaceColor','b'};
arenaArgs          = {'LineWidth',1,'EdgeColor',color_get_fg('w','k')};
showLattice        = true;
latticeArgs        = {'EdgeColor',color_get_fg('w','k'),'EdgeAlpha',0.3};
showPreviousTarget = false;
prevTargetArgs     = {'LineWidth',3,'Marker','o','Color',[34,201,98]./255,'MarkerSize',5};
outside_patch_args = {'FaceColor',color_get_fg('k','w'),'EdgeColor',color_get_fg('k','w')};
ind_trials         = [1,numel(all_trials_l2.learning_stage)];
ax1 = plot_func.plot_mouse_prob_gradient(all_trials_l2,ind_trials,[],mouse_idx,use_grid_visits_as_color,force_cumulative_prob,fig_size,gradient_cmap,...
                                         quiverArgs,pcolorArgs,startArgs,targetArgsB,arenaArgs,...
                                         showLattice,latticeArgs,...
                                         showPreviousTarget,prevTargetArgs,[],outside_patch_args,...
                                         all_trials_l2_jk,show_jk_avg,calc_significant_path_args,use_color_quiver);

tgtAh1    = plot_func.plot_lattice_site(ax1(1),all_trials_l2.simParam.L,all_trials_l1.simParam.food_site,targetArgsA{:});
tgtAh2    = plot_func.plot_lattice_site(ax1(2),all_trials_l2.simParam.L,all_trials_l1.simParam.food_site,targetArgsA{:});
[~ ,~  ]  = plot_func.set_point_label(ax1(1),'start'  ,'Start','Color',color_get_fg('w','k')                                         ,'FontSize',10,'HorizontalAlignment','left','VerticalAlignment','bottom','Padding',[0.4,0]);
[~ ,~  ]  = plot_func.set_point_label(ax1(2),'start'  ,'Start','Color',color_get_fg('w','k')                                         ,'FontSize',10,'HorizontalAlignment','left','VerticalAlignment','bottom','Padding',[0.4,0]);
[~ ,lh1]  = plot_func.set_point_label(ax1(1),'target' ,'B'    ,'Color',func.getParamValue('MarkerFaceColor',targetArgsB,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','right' ,'VerticalAlignment','bottom','Padding',[-0.3,0.2],'BackgroundColor',[1,1,1,0.0]);
[~ ,~  ]  = plot_func.set_point_label(ax1(2),'target' ,'B'    ,'Color',func.getParamValue('MarkerFaceColor',targetArgsB,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','right' ,'VerticalAlignment','top'   ,'Padding',[-0.3,0.2],'BackgroundColor',[1,1,1,0.0]);
[~ ,~  ]  = plot_func.set_point_label(ax1(1),'targetA','A'    ,'Color',func.getParamValue('Color',targetArgsA,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','left' ,'VerticalAlignment','bottom','Padding',[ 0.1,-0.1],'BackgroundColor',[1,1,1,0.0]);
[~ ,~  ]  = plot_func.set_point_label(ax1(2),'targetA','A'    ,'Color',func.getParamValue('Color',targetArgsA,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','left' ,'VerticalAlignment','bottom','Padding',[ 0.1,-0.1],'BackgroundColor',[1,1,1,0.0]);
uistack(lh1   ,'top');
uistack(tgtAh1,'top');
uistack(tgtAh2,'top');

ax1(1).Parent.Color = color_bg;
axis(ax1(1),'off');
axis(ax1(2),'off');
set(ax1(1).Title,'String',['2-targets, ',lower(ax1(1).Title.String),'-B'],'Color',color_get_fg('w','k'),'FontWeight','bold');
set(ax1(2).Title,'String',['2-targets, ',lower(ax1(2).Title.String),'-B'],'Color',color_get_fg('w','k'),'FontWeight','bold');

cbh = colorbar(ax1(2),'Position',[0.5134 0.4070 0.0129 0.0750],'Box','off','Color',color_get_fg('w','k'),'Orientation','vertical','Location','westoutside');
set(cbh      ,'Ticks',minmax(cbh.Ticks),'TickLabels',{'0','high'});
set(cbh.Title,'String',{'Step', 'prob.', 'grad.','(intensity)'},'Color',color_get_fg('w','k'));

rescale_to_target = [false,true];
displ_arrow_prop  = {'LineWidth',3,'Color','m','MaxHeadSize',0.6,'DisplayName','TEV (vector sum of steps)'};
for i = 1:numel(ax1)
    % mouse estimate vector
    [mouse_estimate,v_unit,v_norm,v_norm_std,r0] = func.calc_mouse_estimate_vector(all_trials_l2.sites_per_stage{ind_trials(i)},all_trials_l2.simParam,10,rescale_to_target(i));
    
    % calculating mouse estimate direction stddev
    mouse_estimate_jk     = func.calc_mouse_estimate_vector(import.get_sites_for_learning_stage(all_trials_l2_jk,ind_trials(i)),all_trials_l2_jk{1}.simParam,0,false);
    mouse_estimate_jk_std = func.angle_stddev(cell2mat(mouse_estimate_jk'),'mean');
    theta_mouse_estimate  = atan2(mouse_estimate(2),mouse_estimate(1));
    
    plot_func.myplotv(mouse_estimate,r0,ax1(i),'HandleVisibility','off',displ_arrow_prop{:});
    plot_func.circle_sector(ax1(i),r0,vecnorm(mouse_estimate),theta_mouse_estimate+mouse_estimate_jk_std.*[-1/2,1/2],'m',100,'FaceAlpha',0.25,'HandleVisibility','off');
end


ax_temp=axes;
%plot_func.myplotv(NaN(1,2),[],ax_temp,displ_arrow_prop{:});
plot_func.myplotv([-999,-999],[-990,-990],ax_temp,displ_arrow_prop{:});
set(ax_temp,'XLim',[0,1],'YLim',[0,1]);
legend(ax_temp,'Box','off','Color','k','TextColor',color_get_fg('w','k'));
axis(ax_temp,'off');



% panel_labels = 'ab';
% for k = 1:numel(ax1)
%     text(ax1(k),ax1(k).XLim(1),ax1(k).YLim(1),[panel_labels(k),'.'],'Color',color_get_fg('w','k'),'FontWeight','bold','FontSize',22,'HorizontalAlignment','left','VerticalAlignment','top');
% end

if save_output_figures
    plot_func.saveFigure(ax1(1).Parent,fullfile(outputDir,sprintf('grad_map_2targets_tgt-B_%gdeg',stddev_threshold)),'png',true,{'Color',color_bg,'InvertHardcopy','off'},300);
end


%% 2-targets -- Probe 2 A-B

show_jk_avg                 = true;
calc_significant_path_args  = {stddev_threshold*pi/180,'mean'};
use_color_quiver            = true;

fig_size           = [500,350];
gradient_cmap      = @plot_func.cmap_myjet;
quiverArgs         = {'Color',color_get_fg('w','k'),'LineWidth',1.5,'MaxHeadSize',10000,'Scale',1.1};
pcolorArgs         = {'FaceAlpha',0.6};
startArgs          = {'LineWidth',2,'MarkerSize',8,'Color',color_get_fg('w','k'),'MarkerFaceColor',color_get_fg('k','w')};
targetArgsA        = {'LineWidth',1.5,'Marker','o','Color','r','MarkerSize',7,'MarkerFaceColor',color_get_fg('k','w')};
targetArgsB        = {'LineWidth',1.5,'Marker','o','Color','b','MarkerSize',7,'MarkerFaceColor',color_get_fg('k','w'),'DisplayName','targetB'};
arenaArgs          = {'LineWidth',1,'EdgeColor',color_get_fg('w','k')};
showLattice        = true;
latticeArgs        = {'EdgeColor',color_get_fg('w','k'),'EdgeAlpha',0.3};
showPreviousTarget = false;
prevTargetArgs     = {'LineWidth',3,'Marker','o','Color',[34,201,98]./255,'MarkerSize',5};
outside_patch_args = {'FaceColor',color_get_fg('k','w'),'EdgeColor',color_get_fg('k','w')};
ind_trials         = 1;
ax1 = plot_func.plot_mouse_prob_gradient(all_trials_p2,ind_trials,[],mouse_idx,use_grid_visits_as_color,force_cumulative_prob,fig_size,gradient_cmap,...
                                         quiverArgs,pcolorArgs,startArgs,targetArgsA,arenaArgs,...
                                         showLattice,latticeArgs,...
                                         showPreviousTarget,prevTargetArgs,[],outside_patch_args,...
                                         all_trials_p2_jk,show_jk_avg,calc_significant_path_args,use_color_quiver);

tgtAh2    = plot_func.plot_lattice_site(ax1,all_trials_p2.simParam.L,all_trials_l2.simParam.food_site,targetArgsB{:});
[~,~  ]  = plot_func.set_point_label(ax1,'start'   ,'Start','Color',color_get_fg('w','k')                                         ,'FontSize',10,'HorizontalAlignment','left','VerticalAlignment','bottom','Padding',[0.4,0]);
[~,lh1]  = plot_func.set_point_label(ax1,'targetB' ,'B'    ,'Color',func.getParamValue('Color',targetArgsB,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','left' ,'VerticalAlignment','bottom','Padding',[ 0.0, 0.0],'BackgroundColor',[1,1,1,0.0]);
[~,~  ]  = plot_func.set_point_label(ax1,'target'  ,'A'    ,'Color',func.getParamValue('Color',targetArgsA,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','left' ,'VerticalAlignment','bottom','Padding',[ 0.1,-0.1],'BackgroundColor',[1,1,1,0.0]);
uistack(lh1   ,'top');
uistack(tgtAh2,'top');

ax1.Parent.Color = color_bg;
axis(ax1,'off');
set(ax1(1).Title,'String','2-targets, Probe B-A','Color',color_get_fg('w','k'),'FontWeight','bold');

cbh = colorbar(ax1,'Position',[0.1460 0.3571 0.0203 0.1111],'Box','off','Color',color_get_fg('w','k'),'Orientation','vertical','Location','westoutside');
set(cbh      ,'Ticks',minmax(cbh.Ticks),'TickLabels',{'0','high'});
set(cbh.Title,'String',{'Step', 'prob.', 'grad.','(intensity)'},'Color',color_get_fg('w','k'));



% position ot target B (start point)
r_B              = func.myind2sub(L,all_trials_p2.simParam.food_site,true);
% distance between targets (to rescale mouse estimate vector)
d_AB             = arena.calc_lattice_site_distance(all_trials_l1.simParam.food_site,all_trials_p2.simParam.food_site,[L,L]); %d_tgt=7;
displ_arrow_prop = {'LineWidth',3,'Color','m','MaxHeadSize',0.4,'DisplayName','TEV (vector sum of steps)'};
for i = 1:numel(ax1)
    % mouse estimate vector
    [mouse_estimate,v_unit,v_norm,v_norm_std,r0] = func.calc_mouse_estimate_vector(all_trials_p2.sites_per_stage{ind_trials(i)},all_trials_p2.simParam,10,d_AB);
    
    % calculating mouse estimate direction stddev
    mouse_estimate_jk     = func.calc_mouse_estimate_vector(import.get_sites_for_learning_stage(all_trials_p2_jk,ind_trials(i)),all_trials_p2_jk{1}.simParam,0,false);
    mouse_estimate_jk_std = func.angle_stddev(cell2mat(mouse_estimate_jk'),'mean');
    theta_mouse_estimate  = atan2(mouse_estimate(2),mouse_estimate(1));
    
    plot_func.myplotv(mouse_estimate,r_B,ax1(i),'HandleVisibility','off',displ_arrow_prop{:});
    plot_func.circle_sector(ax1(i),r_B,vecnorm(mouse_estimate),theta_mouse_estimate+mouse_estimate_jk_std.*[-1/2,1/2],'m',100,'FaceAlpha',0.25,'HandleVisibility','off');
end


ax_temp=axes;
%plot_func.myplotv(NaN(1,2),[],ax_temp,displ_arrow_prop{:});
plot_func.myplotv([-999,-999],[-990,-990],ax_temp,displ_arrow_prop{:});
set(ax_temp,'XLim',[0,1],'YLim',[0,1]);
legend(ax_temp,'Box','off','Color','k','TextColor',color_get_fg('w','k'),'Location','southoutside');
axis(ax_temp,'off');





% panel_labels = 'ab';
% for k = 1:numel(ax1)
%     text(ax1(k),ax1(k).XLim(1),ax1(k).YLim(1),[panel_labels(k),'.'],'Color',color_get_fg('w','k'),'FontWeight','bold','FontSize',22,'HorizontalAlignment','left','VerticalAlignment','top');
% end

if save_output_figures
    plot_func.saveFigure(ax1.Parent,fullfile(outputDir,sprintf('grad_map_2targets_probe2_A-B_%gdeg',stddev_threshold)),'png',true,{'Color',color_bg,'InvertHardcopy','off'},300);
end

%% 2-targets -- Probe 2 A-B R180 


show_jk_avg                 = true;
calc_significant_path_args  = {stddev_threshold*pi/180,'mean'};
use_color_quiver            = true;

fig_size           = [500,350];
gradient_cmap      = @plot_func.cmap_myjet;
quiverArgs         = {'Color',color_get_fg('w','k'),'LineWidth',1.5,'MaxHeadSize',10000,'Scale',1.1};
pcolorArgs         = {'FaceAlpha',0.6};
startArgs          = {'LineWidth',2,'MarkerSize',7,'Color',0.6.*ones(1,3),'Marker','d','Padding',[0,0.5],'MarkerFaceColor',color_get_fg('k','w'),'DisplayName','startT'};
startArgsREL       = {'LineWidth',2,'MarkerSize',8,'Color',color_get_fg('w','k'),'Marker','s','MarkerFaceColor',color_get_fg('k','w')};
targetArgsA        = {'LineWidth',1.5,'Marker','o','Color','r','MarkerSize',7,'MarkerFaceColor',color_get_fg('k','w'),'DisplayName','targetA'};
targetArgsB        = {'LineWidth',1.5,'Marker','o','Color','b','MarkerSize',7,'MarkerFaceColor',color_get_fg('k','w'),'DisplayName','targetB'};
targetArgsAREL     = {'LineWidth',2,'Marker','^','Color',[170, 15, 15]./255,'MarkerSize',8,'MarkerFaceColor',color_get_fg('k','w'),'DisplayName','targetAREL'};
targetArgsBREL     = {'LineWidth',2,'Marker','^','Color',[ 31, 31,183]./255,'MarkerSize',8,'MarkerFaceColor',color_get_fg('k','w'),'DisplayName','targetBREL'};
arenaArgs          = {'LineWidth',1,'EdgeColor',color_get_fg('w','k')};
showLattice        = true;
latticeArgs        = {'EdgeColor',color_get_fg('w','k'),'EdgeAlpha',0.3};
showPreviousTarget = false;
prevTargetArgs     = {'LineWidth',3,'Marker','o','Color',[34,201,98]./255,'MarkerSize',5};
outside_patch_args = {'FaceColor',color_get_fg('k','w'),'EdgeColor',color_get_fg('k','w')};
ind_trials         = 1;
ax1 = plot_func.plot_mouse_prob_gradient(all_trials_p2_rot,ind_trials,[],mouse_idx,use_grid_visits_as_color,force_cumulative_prob,fig_size,gradient_cmap,...
                                         quiverArgs,pcolorArgs,startArgsREL,targetArgsBREL,arenaArgs,...
                                         showLattice,latticeArgs,...
                                         showPreviousTarget,prevTargetArgs,[],outside_patch_args,...
                                         all_trials_p2_rot_jk,show_jk_avg,calc_significant_path_args,use_color_quiver);

start_pos = arena.get_start_position(arena.rotate_start_label(all_trials_p2_rot.simParam.start_pos,pi),all_trials_p2_rot.simParam.shape,all_trials_p2_rot.simParam.L);
startAh1  = plot_func.plot_lattice_site(ax1,all_trials_p2_rot.simParam.L,start_pos,startArgs{:});
%tgtAh1    = plot_func.plot_lattice_site(ax1,all_trials_p2_rot.simParam.L,all_trials_p2_rot.learning_stage.target       ,'Marker','o','Color','k');%targetArgsA{:});
tgtAh2    = plot_func.plot_lattice_site(ax1,all_trials_p2_rot.simParam.L,all_trials_p2_rot.learning_stage.target_alt   ,targetArgsAREL{:});%'Marker','s','Color','k');%targetArgsA{:});
tgtAh3    = plot_func.plot_lattice_site(ax1,all_trials_p2_rot.simParam.L,all_trials_p2_rot.learning_stage.target_rev   ,targetArgsB{:});%'Marker','^','Color','k');%targetArgsA{:});
tgtAh4    = plot_func.plot_lattice_site(ax1,all_trials_p2_rot.simParam.L,all_trials_p2_rot.learning_stage.target_revalt,targetArgsA{:});%'Marker','v','Color','k');%targetArgsA{:});

[~,~  ]  = plot_func.set_point_label(ax1,'start'      ,'Start'             ,'Color',color_get_fg('w','k')                                         ,'FontSize',10,'HorizontalAlignment','left','VerticalAlignment','top'   ,'Padding',[-0.3,0]);
[~,~  ]  = plot_func.set_point_label(ax1,'startT'     ,'Start on Training' ,'Color',func.getParamValue('Color',startArgs    ,false)               ,'FontSize',10,'HorizontalAlignment','left','VerticalAlignment','bottom','Padding',[-0.3,0]);
[~,~  ]  = plot_func.set_point_label(ax1,'targetA'    ,'A'                 ,'Color',func.getParamValue('Color',targetArgsA,false)   ,'FontSize',14,'FontWeight','bold','HorizontalAlignment','left' ,'VerticalAlignment','bottom','Padding',[ 0.1, 0.1],'BackgroundColor',[1,1,1,0.0]);
[~,~  ]  = plot_func.set_point_label(ax1,'targetB'    ,'B'                 ,'Color',func.getParamValue('Color',targetArgsB,false)   ,'FontSize',14,'FontWeight','bold','HorizontalAlignment','left' ,'VerticalAlignment','bottom','Padding',[ 0.0, 0.0],'BackgroundColor',[1,1,1,0.0]);
[~,~  ]  = plot_func.set_point_label(ax1,'targetAREL' ,'REL A'             ,'Color',func.getParamValue('Color',targetArgsAREL,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','left' ,'VerticalAlignment','top'   ,'Padding',[ -0.3, 0.1],'BackgroundColor',[1,1,1,0.0]);
[~,lh1]  = plot_func.set_point_label(ax1,'targetBREL' ,'REL B'             ,'Color',func.getParamValue('Color',targetArgsBREL,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','left' ,'VerticalAlignment','bottom','Padding',[ -0.1, 0.1],'BackgroundColor',[1,1,1,0.0]);
uistack(lh1   ,'top');
%uistack(tgtAh1,'top');
uistack(tgtAh2,'top');
uistack(tgtAh3,'top');
uistack(tgtAh4,'top');

ax1.Parent.Color = color_bg;
axis(ax1,'off');
set(ax1(1).Title,'String','2-targets, Probe B-A 180^o','Color',color_get_fg('w','k'),'FontWeight','bold');

ax1.XDir = 'reverse';
ax1.YDir = 'normal';

cbh = colorbar(ax1,'Position',[0.1460 0.3571 0.0203 0.1111],'Box','off','Color',color_get_fg('w','k'),'Orientation','vertical','Location','westoutside');
set(cbh      ,'Ticks',minmax(cbh.Ticks),'TickLabels',{'0','high'});
set(cbh.Title,'String',{'Step', 'prob.', 'grad.','(intensity)'},'Color',color_get_fg('w','k'));


% position ot target B (start point)
r_B              = func.myind2sub(L,all_trials_p2_rot.simParam.food_site,true);
% distance between targets (to rescale mouse estimate vector)
d_AB             = arena.calc_lattice_site_distance(all_trials_l1.simParam.food_site,all_trials_p2_rot.simParam.food_site,[L,L]); %d_tgt=7;
displ_arrow_prop = {'LineWidth',3,'Color','m','MaxHeadSize',0.4,'DisplayName','TEV (vector sum of steps)'};
for i = 1:numel(ax1)
    % mouse estimate vector
    [mouse_estimate,v_unit,v_norm,v_norm_std,r0] = func.calc_mouse_estimate_vector(all_trials_p2_rot.sites_per_stage{ind_trials(i)},all_trials_p2_rot.simParam,10,d_AB);
    %                                                                             (                                 sites                                 ,             simParam     ,nbootstrap_samples,rescale_to_target_distance,start_site,target_site,calc_significant_path_args)
    % [mouse_estimate,v_unit,v_norm,v_norm_std,r0] = func.calc_mouse_estimate_vector(import.get_sites_for_learning_stage(all_trials_p2_rot_jk,ind_trials(i)),...
    %                                                                                all_trials_p2_rot.simParam,...
    %                                                                                10,           d_AB           ,[],[],...
    %                                                                                calc_significant_path_args);
    
    % calculating mouse estimate direction stddev
    mouse_estimate_jk     = func.calc_mouse_estimate_vector(import.get_sites_for_learning_stage(all_trials_p2_rot_jk,ind_trials(i)),all_trials_p2_rot_jk{1}.simParam,0,false);
    mouse_estimate_jk_std = func.angle_stddev(cell2mat(mouse_estimate_jk'),'mean');
    theta_mouse_estimate  = atan2(mouse_estimate(2),mouse_estimate(1));
    
    plot_func.myplotv(mouse_estimate,r_B,ax1(i),'HandleVisibility','off',displ_arrow_prop{:});
    plot_func.circle_sector(ax1(i),r_B,vecnorm(mouse_estimate),theta_mouse_estimate+mouse_estimate_jk_std.*[-1/2,1/2],'m',100,'FaceAlpha',0.25,'HandleVisibility','off');
end


ax_temp=axes;
%plot_func.myplotv(NaN(1,2),[],ax_temp,displ_arrow_prop{:});
plot_func.myplotv([-999,-999],[-990,-990],ax_temp,displ_arrow_prop{:});
set(ax_temp,'XLim',[0,1],'YLim',[0,1]);
legend(ax_temp,'Box','off','Color','k','TextColor',color_get_fg('w','k'),'Position', [0.0521 0.0555 0.3804 0.0503]);
axis(ax_temp,'off');


if save_output_figures
    plot_func.saveFigure(ax1.Parent,fullfile(outputDir,sprintf('grad_map_2targets_probe2_A-B_%gdeg_R180_REL_PROBE',stddev_threshold)),'png',true,{'Color',color_bg,'InvertHardcopy','off'},300);
end


%% static and random -- detail of directed flow

disp('***************');
disp('*************** ignoring stddev threshold for supplementary figures');
disp('***************');

show_jk_avg                 = true;
calc_significant_path_args  = {pi/2,'mean'};
use_color_quiver            = true;

fig_size           = [1400,600];
gradient_cmap      = @plot_func.cmap_myjet;
quiverArgs         = {'Color','w','LineWidth',1.5,'MaxHeadSize',10000,'Scale',1.1};
pcolorArgs         = {'FaceAlpha',0.6};
startArgs          = {'LineWidth',2,'MarkerSize',8,'Color','k'};
targetArgs         = {'LineWidth',1,'Marker','o','Color','w','MarkerSize',7,'MarkerFaceColor','r'};
arenaArgs          = {'LineWidth',1,'EdgeColor','k'};
showLattice        = true;
latticeArgs        = {'EdgeColor','w','EdgeAlpha',0.5};
showPreviousTarget = false;
prevTargetArgs     = {'LineWidth',3,'Marker','o','Color',[34,201,98]./255,'MarkerSize',5};
ind_trials         = [1,14];
showGradientMagnitude = false;
arena_outside_patch_args = {'FaceColor','w','EdgeColor','none'};
ax1 = plot_func.plot_mouse_prob_gradient({all_trials_ft,all_trials_rt},{ind_trials,ind_trials},4,mouse_idx,use_grid_visits_as_color,force_cumulative_prob,fig_size,gradient_cmap,...
                                         quiverArgs,pcolorArgs,startArgs,targetArgs,arenaArgs,...
                                         showLattice,latticeArgs,...
                                         showPreviousTarget,prevTargetArgs,showGradientMagnitude,arena_outside_patch_args ,...
                                         {all_trials_ft_jk,all_trials_rt_jk},show_jk_avg,calc_significant_path_args,use_color_quiver);


[th,lh]  = plot_func.set_point_label(ax1(1),'start' ,'Start','Color','k'                                         ,'FontSize',9 ,'HorizontalAlignment','left','VerticalAlignment','bottom','Padding',[0.4,0]);
[th,lh]  = plot_func.set_point_label(ax1(2),'start' ,'Start','Color','k'                                         ,'FontSize',9 ,'HorizontalAlignment','left','VerticalAlignment','bottom','Padding',[0.4,0]);
[th,lh]  = plot_func.set_point_label(ax1(1),'target','A'    ,'Color',func.getParamValue('MarkerFaceColor',targetArgs,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','right','VerticalAlignment','top');
[th,lh]  = plot_func.set_point_label(ax1(2),'target','A'    ,'Color',func.getParamValue('MarkerFaceColor',targetArgs,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','right','VerticalAlignment','top','Padding',[-0.4,-0.2],'BackgroundColor',[1,1,1,0.5]);
[th,lh]  = plot_func.set_point_label(ax1(3),'start' ,'Start','Color','k'                                         ,'FontSize',9 ,'HorizontalAlignment','left','VerticalAlignment','bottom','Padding',[0.4,0]);
[th,lh]  = plot_func.set_point_label(ax1(4),'start' ,'Start','Color','k'                                         ,'FontSize',9 ,'HorizontalAlignment','left','VerticalAlignment','bottom','Padding',[0.4,0]);
[th,lh]  = plot_func.set_point_label(ax1(3),'target','A'    ,'Color',func.getParamValue('MarkerFaceColor',targetArgs,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','right','VerticalAlignment','top');
[th,lh]  = plot_func.set_point_label(ax1(4),'target','A'    ,'Color',func.getParamValue('MarkerFaceColor',targetArgs,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','right','VerticalAlignment','top','Padding',[-0.4,-0.2],'BackgroundColor',[1,1,1,0.5]);

ax1(1).Parent.Color = 'w';
axis(ax1,'off');
set(ax1(1).Title,'String',['Random, ',lower(ax1(1).Title.String)],'Color','k','FontWeight','bold');
set(ax1(2).Title,'String',['Random, ',lower(ax1(2).Title.String)],'Color','k','FontWeight','bold');
set(ax1(3).Title,'String',['Static, ',lower(ax1(3).Title.String)],'Color','k','FontWeight','bold');
set(ax1(4).Title,'String',['Static, ',lower(ax1(4).Title.String)],'Color','k','FontWeight','bold');

%panel_labels = 'abcd';
%for k = 1:numel(ax1)
%    text(ax1(k),ax1(k).XLim(1),ax1(k).YLim(1),[panel_labels(k),'.'],'Color','k','FontWeight','bold','FontSize',22,'HorizontalAlignment','left','VerticalAlignment','top');
%end

for i = 1:numel(ax1)
    p0 = ax1(i).Position;
    ax1(i).Position = [ p0(1)-0.1, p0(2)+0.14, p0(3)*1.2, p0(4)*1.2 ];
end

panel_input_cell      = {all_trials_ft,all_trials_ft,all_trials_rt,all_trials_rt};
panel_input_cell_jk   = {all_trials_ft_jk,all_trials_ft_jk,all_trials_rt_jk,all_trials_rt_jk};
ind_trials            = [1,14,1,14];
trial_labels          = {'Random 1','Random 14', 'Static 1', 'Static 14'};
step_displacement     = zeros(size(ind_trials));
step_displacement_std = zeros(size(ind_trials));
rescale_to_target     = [false,false,false,true];

ax2                = gobjects(1,numel(panel_input_cell));
p0                 = [ax1(1).Position(1)+0.02,0.2,ax1(1).Position(3)*0.8,0.3];
maxheadsize_values = [0.85,0.6,0.6,0.4];
for i = 1:numel(panel_input_cell)
    p = p0;
    p(1) = ax1(i).Position(1)+0.02;
    ax2(i) = axes('Position',p,'Box','on');
    hold(ax2(i),'on');

    % gradient vectors
    G = arena.calc_prob_gradient_with_positions(panel_input_cell{i}.sites_per_stage{ind_trials(i)},panel_input_cell{i}.simParam.L,true,[],import.get_sites_for_learning_stage(panel_input_cell_jk{i},ind_trials(i)),show_jk_avg,calc_significant_path_args);
    
    % mouse estimate vector
    [mouse_estimate,v_unit,step_displacement(i),step_displacement_std(i),r0] = func.calc_mouse_estimate_vector(panel_input_cell{i}.sites_per_stage{ind_trials(i)},panel_input_cell{i}.simParam,10,rescale_to_target(i));
    
    % calculating mouse estimate direction stddev
    mouse_estimate_jk     = func.calc_mouse_estimate_vector(import.get_sites_for_learning_stage(panel_input_cell_jk{i},ind_trials(i)),panel_input_cell_jk{i}{1}.simParam,0,false);
    mouse_estimate_jk_std = func.angle_stddev(cell2mat(mouse_estimate_jk'),'mean');
    theta_mouse_estimate  = atan2(mouse_estimate(2),mouse_estimate(1));
    
    plot_func.myplotv(mouse_estimate,r0,ax1(i),'LineWidth',2,'Color',[10,200,20]./255,'MaxHeadSize',maxheadsize_values(i),'DisplayName','Displacement direction','HandleVisibility','off');
    plot_func.circle_sector(ax1(i),r0,vecnorm(mouse_estimate),theta_mouse_estimate+mouse_estimate_jk_std.*[-1/2,1/2],[10,200,20]./255,100,'FaceAlpha',0.3,'HandleVisibility','off');
    
    plot_func.myplotv(G,[],ax2(i),'LineWidth',0.1,'Color',[0,0,0,0.5],'HandleVisibility','off');
    %plot_func.myplotv(Gm  ,'LineWidth', 2,'Color','r');
    plot(ax2(i),[0,0],[-1,1],'--m','LineWidth',1,'HandleVisibility','off');
    plot(ax2(i),[-1,1],[0,0],'--m','LineWidth',1,'HandleVisibility','off');
    plot_func.myplotv(v_unit.*[1,-1],[],ax2(i),'LineWidth',2,'Color',[10,200,20]./255,'MaxHeadSize',0.5,'DisplayName','TEV (vector sum of steps)');
    plot_func.circle_sector(ax2(i),[0,0],1,-theta_mouse_estimate+mouse_estimate_jk_std.*[1/2,-1/2],[10,200,20]./255,100,'FaceAlpha',0.3,'HandleVisibility','off');
    xlabel(ax2(i),'x');
    ylabel(ax2(i),'y');
    legend(ax2(i),'Location','northoutside');
end


axis(ax2,'square');

figure(ax1(1).Parent);
ax3  = axes('Position', [0.8601 0.3750 0.0926 0.3127]);
hold(ax3,'on');
for k = 1:numel(panel_input_cell)
    errorbar(ax3,k,step_displacement(k),step_displacement_std(k),'D','LineWidth',2,'MarkerFaceColor','w','MarkerSize',10);
end
ylabel(ax3,'Normalized displacement');
xlabel(ax3,'Trial');
set(ax3,'FontSize',12,'XTick',1:numel(panel_input_cell),'XTickLabels',trial_labels,'XTickLabelRotation',45,'XLim',[0,numel(panel_input_cell)]+0.5);

if save_output_figures
    plot_func.saveFigure(ax1(1).Parent,fullfile(outputDir,sprintf('grad_map_static_flow_detail_%gdeg',stddev_threshold)),'png',true,{'Color','w','InvertHardcopy','off'},300);
end



%% 2-targets -- detail of directed flow

disp('***************');
disp('*************** ignoring stddev threshold for supplementary figures');
disp('***************');

show_jk_avg                 = true;
calc_significant_path_args  = {pi/2,'mean'};
use_color_quiver            = true;


fig_size           = [1400,600];
gradient_cmap      = @plot_func.cmap_myjet;
quiverArgs         = {'Color','w','LineWidth',1.5,'MaxHeadSize',10000,'Scale',1.1};
pcolorArgs         = {'FaceAlpha',0.6};
startArgs          = {'LineWidth',2,'MarkerSize',8,'Color','k'};
%targetArgsA        = {'LineWidth',1.5,'Marker','o','Color','r','MarkerSize',5,'MarkerFaceColor','w'};
targetArgsA_fill   = {'LineWidth',1,'Marker','o','Color','w','MarkerSize',7,'MarkerFaceColor','r','DisplayName','targetA'};
targetArgsB_fill   = {'LineWidth',1,'Marker','o','Color','w','MarkerSize',7,'MarkerFaceColor','b','DisplayName','targetB'};
targetArgsA_empty  = {'LineWidth',1.5,'Marker','o','Color','r','MarkerSize',7,'MarkerFaceColor','none','DisplayName','targetA'};
targetArgsB_empty  = {'LineWidth',1.5,'Marker','o','Color','b','MarkerSize',7,'MarkerFaceColor','none','DisplayName','targetB'};
arenaArgs          = {'LineWidth',1,'EdgeColor','k','FaceColor','none'};
showLattice        = true;
latticeArgs        = {'EdgeColor','w','EdgeAlpha',0.5};
showPreviousTarget = false;
prevTargetArgs     = {'LineWidth',3,'Marker','o','Color',[34,201,98]./255,'MarkerSize',5};
ind_trials         = { 16, [1,numel(all_trials_l2.learning_stage)],1 };
showGradientMagnitude    = false;
arena_outside_patch_args = {'FaceColor','w','EdgeColor','none'};
ax1 = plot_func.plot_mouse_prob_gradient({all_trials_l1,all_trials_l2,all_trials_p2},ind_trials,4,mouse_idx,use_grid_visits_as_color,force_cumulative_prob,fig_size,gradient_cmap,...
                                         quiverArgs,pcolorArgs,startArgs,{targetArgsA_fill,targetArgsB_fill,targetArgsB_empty},arenaArgs,...
                                         showLattice,latticeArgs,...
                                         showPreviousTarget,prevTargetArgs,showGradientMagnitude,arena_outside_patch_args ,...
                                         {all_trials_l1_jk,all_trials_l2_jk,all_trials_p2_jk},show_jk_avg,calc_significant_path_args,use_color_quiver);

%tgtBh1    = plot_func.plot_lattice_site(ax1(1),all_trials_l1.simParam.L,all_trials_l2.simParam.food_site,targetArgsB{:});
%tgtBh2    = plot_func.plot_lattice_site(ax1(2),all_trials_l1.simParam.L,all_trials_l2.simParam.food_site,targetArgsB{:});
tgtAh2    = plot_func.plot_lattice_site(ax1(2),all_trials_l2.simParam.L,all_trials_l1.simParam.food_site,targetArgsA_empty{:});
tgtAh3    = plot_func.plot_lattice_site(ax1(3),all_trials_l2.simParam.L,all_trials_l1.simParam.food_site,targetArgsA_empty{:});
tgtAh4    = plot_func.plot_lattice_site(ax1(4),all_trials_p2.simParam.L,all_trials_l1.simParam.food_site,targetArgsA_empty{:});
[th,lh ]  = plot_func.set_point_label(ax1(1),'start'  ,'Start','Color','k'                                          ,'FontSize',9 ,'HorizontalAlignment','left','VerticalAlignment','bottom','Padding',[0.4,0]);
[th,lh ]  = plot_func.set_point_label(ax1(2),'start'  ,'Start','Color','k'                                          ,'FontSize',9 ,'HorizontalAlignment','left','VerticalAlignment','bottom','Padding',[0.4,0]);
[th,lh ]  = plot_func.set_point_label(ax1(3),'start'  ,'Start','Color','k'                                          ,'FontSize',9 ,'HorizontalAlignment','left','VerticalAlignment','bottom','Padding',[0.4,0]);
[th,lh ]  = plot_func.set_point_label(ax1(4),'start'  ,'Start','Color','k'                                          ,'FontSize',9 ,'HorizontalAlignment','left','VerticalAlignment','bottom','Padding',[0.4,0]);
[th,lh ]  = plot_func.set_point_label(ax1(1),'targetA','A'    ,'Color',func.getParamValue('MarkerFaceColor',targetArgsA_fill,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','left' ,'VerticalAlignment','bottom','Padding',[+0.4,+0.2]);
[th,lh1]  = plot_func.set_point_label(ax1(2),'targetB','B'    ,'Color',func.getParamValue('MarkerFaceColor',targetArgsB_fill,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','left' ,'VerticalAlignment','bottom','Padding',[ 0.0, 0.0]);
[th,~  ]  = plot_func.set_point_label(ax1(2),'targetA','A'    ,'Color',func.getParamValue('MarkerFaceColor',targetArgsA_fill,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','left' ,'VerticalAlignment','bottom','Padding',[ 0.0, 0.0]);
[th,lh1]  = plot_func.set_point_label(ax1(3),'targetB','B'    ,'Color',func.getParamValue('MarkerFaceColor',targetArgsB_fill,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','left' ,'VerticalAlignment','bottom','Padding',[ 0.0, 0.0]);
[th,~  ]  = plot_func.set_point_label(ax1(3),'targetA','A'    ,'Color',func.getParamValue('MarkerFaceColor',targetArgsA_fill,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','left' ,'VerticalAlignment','bottom','Padding',[ 0.0, 0.0]);
[th,lh1]  = plot_func.set_point_label(ax1(4),'targetB','B'    ,'Color',func.getParamValue('MarkerFaceColor',targetArgsB_fill,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','left' ,'VerticalAlignment','bottom','Padding',[ 0.0, 0.0]);
[th,~  ]  = plot_func.set_point_label(ax1(4),'targetA','A'    ,'Color',func.getParamValue('MarkerFaceColor',targetArgsA_fill,false),'FontSize',14,'FontWeight','bold','HorizontalAlignment','left' ,'VerticalAlignment','bottom','Padding',[ 0.0, 0.0]);


ax1(1).Parent.Color = 'w';
axis(ax1,'off');
set(ax1(1).Title,'String',sprintf('2-targets, %g-A',ind_trials{1}),'Color','k','FontWeight','bold');
set(ax1(2).Title,'String',['2-targets, ',lower(ax1(2).Title.String),'-B'],'Color','k','FontWeight','bold');
set(ax1(3).Title,'String',['2-targets, ',lower(ax1(3).Title.String),'-B'],'Color','k','FontWeight','bold');
set(ax1(4).Title,'String','2-targets, probe B\rightarrow A','Color','k','FontWeight','bold');


for i = 1:numel(ax1)
    p0 = ax1(i).Position;
    ax1(i).Position = [ p0(1)-0.1, p0(2)+0.14, p0(3)*1.2, p0(4)*1.2 ];
end



G1_l1 = arena.calc_prob_gradient_with_positions(all_trials_l1.sites_per_stage{14},all_trials_l1.simParam.L,true);
G1_l2 = arena.calc_prob_gradient_with_positions(all_trials_l2.sites_per_stage{1} ,all_trials_l2.simParam.L,true);
G2_l2 = arena.calc_prob_gradient_with_positions(all_trials_l2.sites_per_stage{8} ,all_trials_l2.simParam.L,true);
G1_p2 = arena.calc_prob_gradient_with_positions(all_trials_p2.sites_per_stage{1} ,all_trials_p2.simParam.L,true);


G = {G1_l1,G1_l2,G2_l2,G1_p2};


% position ot target B (start point)
r_B              = func.myind2sub(L,all_trials_p2.simParam.food_site,true);
% distance between targets (to rescale mouse estimate vector)
d_AB             = arena.calc_lattice_site_distance(all_trials_l1.simParam.food_site,all_trials_p2.simParam.food_site,[L,L]); %d_tgt=7;

panel_input_cell      = {all_trials_l1,all_trials_l2,all_trials_l2,all_trials_p2};
panel_input_cell_jk   = {all_trials_l1_jk,all_trials_l2_jk,all_trials_l2_jk,all_trials_p2_jk};
ind_trials            = [14,1,8,1]; % index of the trial to plot for each input file in panel_input_cell
trial_labels          = {'Trial 14-A','Trial 1-B', 'Trial 8-B', 'Probe A-B'};
step_displacement     = zeros(size(ind_trials));
step_displacement_std = zeros(size(ind_trials));
rescale_to_target     = [true,false,true,d_AB];

ax2 = gobjects(1,numel(panel_input_cell));
p0  = [ax1(1).Position(1)+0.02,0.2,ax1(1).Position(3)*0.8,0.3];
maxheadsize_values = [0.4,0.6,0.6,0.4];
for i = 1:numel(panel_input_cell)
    p = p0;
    p(1) = ax1(i).Position(1)+0.02;
    ax2(i) = axes('Position',p,'Box','on');
    hold(ax2(i),'on');
    
    % gradient vectors
    G = arena.calc_prob_gradient_with_positions(panel_input_cell{i}.sites_per_stage{ind_trials(i)} ,panel_input_cell{i}.simParam.L,true,[],import.get_sites_for_learning_stage(panel_input_cell_jk{i},ind_trials(i)),show_jk_avg,calc_significant_path_args);

    % mouse estimate vector
                                                                              %     calc_mouse_estimate_vector(sites                                             ,                    simParam,nbootstrap_samples,rescale_to_target_distance,start_site,target_site) 
    [mouse_estimate,v_unit,step_displacement(i),step_displacement_std(i),r0] = func.calc_mouse_estimate_vector(panel_input_cell{i}.sites_per_stage{ind_trials(i)},panel_input_cell{i}.simParam,                10,rescale_to_target(i)      );
    
    % calculating mouse estimate direction stddev
    mouse_estimate_jk     = func.calc_mouse_estimate_vector(import.get_sites_for_learning_stage(panel_input_cell_jk{i},ind_trials(i)),panel_input_cell_jk{i}{1}.simParam,0,false);
    mouse_estimate_jk_std = func.angle_stddev(cell2mat(mouse_estimate_jk'),'mean');
    theta_mouse_estimate  = atan2(mouse_estimate(2),mouse_estimate(1));
    
    if i == numel(panel_input_cell)
        r_start = r_B;
    else
        r_start = r0;
    end
    
    plot_func.myplotv(mouse_estimate,r_start,ax1(i),'LineWidth',2,'Color',[10,200,20]./255,'MaxHeadSize',maxheadsize_values(i),'DisplayName','Displacement direction','HandleVisibility','off');
    plot_func.circle_sector(ax1(i),r_start,vecnorm(mouse_estimate),theta_mouse_estimate+mouse_estimate_jk_std.*[-1/2,1/2],[10,200,20]./255,100,'FaceAlpha',0.3,'HandleVisibility','off');
    
    plot_func.myplotv(G,[],ax2(i),'LineWidth',0.1,'Color',[0,0,0,0.5],'HandleVisibility','off');
    plot(ax2(i),[0,0],[-1,1],'--m','LineWidth',1,'HandleVisibility','off');
    plot(ax2(i),[-1,1],[0,0],'--m','LineWidth',1,'HandleVisibility','off');
    plot_func.myplotv(v_unit.*[1,-1],[],ax2(i),'LineWidth',2,'Color',[10,200,20]./255,'MaxHeadSize',0.5,'DisplayName','TEV (vector sum of steps)');
    plot_func.circle_sector(ax2(i),[0,0],1,-theta_mouse_estimate+mouse_estimate_jk_std.*[1/2,-1/2],[10,200,20]./255,100,'FaceAlpha',0.3,'HandleVisibility','off');
    xlabel(ax2(i),'x');
    ylabel(ax2(i),'y');
    legend(ax2(i),'Location','northoutside');
end

axis(ax2,'square');

figure(ax1(1).Parent);
ax3  = axes('Position', [0.8704 0.3830 0.0926 0.3127]);
hold(ax3,'on');
for k = 1:numel(panel_input_cell)
    errorbar(ax3,k,step_displacement(k),step_displacement_std(k),'D','LineWidth',2,'MarkerFaceColor','w','MarkerSize',10);
end
ylabel(ax3,'Normalized displacement');
xlabel(ax3,'Trial');
set(ax3,'FontSize',12,'XTick',1:numel(panel_input_cell),'XTickLabels',trial_labels,'XTickLabelRotation',45,'XLim',[0,numel(panel_input_cell)]+0.5);
title(ax3,{'This boxplot','is plotted in','fig\_paper\_2targets\_analysis.ipynb'},'FontSize',8,'Position',[2.75,11.34,0]);

if save_output_figures
    plot_func.saveFigure(ax1(1).Parent,fullfile(outputDir,sprintf('grad_map_2targets_flow_detail_%gdeg',stddev_threshold)),'png',true,{'Color','w','InvertHardcopy','off'},300);
end