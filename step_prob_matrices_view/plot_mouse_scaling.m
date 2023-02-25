clearvars
close all

set(0, 'defaulttextfontname', 'Arial')
set(0, 'defaultaxesfontname', 'Arial')

mouse_dir_ft = '../step_prob_matrices/fixed_target';
mouse_dir_rt = '../step_prob_matrices/relative_target';
mouse_dir_t1 = '../step_prob_matrices/two_target_no_cues_tgt1';
mouse_dir_t2 = '../step_prob_matrices/two_target_no_cues_tgt2';


outputDir = '../figs/paper/step_prob';

if exist(outputDir,'dir') ~= 7
    mkdir(outputDir);
end

save_output_figures = true;

L_values = [11,21,31,41,51];


disp('loading experimental data ...')

si_ft = arrayfun(@(L) import.import_mouse_stepmat(fullfile(mouse_dir_ft,'independent/ntrials_14/stopfood/Pinit025',sprintf('stepmat_nose_L_%g_nstages_14_ntrials_14_Pinit_0.25_indept_stopfood_align_tgt.mat',L)),'trial'),...
                 L_values,'UniformOutput',false);
si_rt = arrayfun(@(L) import.import_mouse_stepmat(fullfile(mouse_dir_rt,'independent/ntrials_14/stopfood/Pinit025',sprintf('stepmat_nose_L_%g_nstages_14_ntrials_14_Pinit_0.25_indept_stopfood_align_ent.mat',L)),'trial'),...
                 L_values,'UniformOutput',false);
si_t1 = arrayfun(@(L) import.import_mouse_stepmat(fullfile(mouse_dir_t1,'independent/ntrials_18/stopfood/Pinit025',sprintf('stepmat_nose_L_%g_nstages_18_ntrials_18_Pinit_0.25_indept_stopfood_align_ent.mat',L)),'trial'),...
                 L_values,'UniformOutput',false);
si_t2 = arrayfun(@(L) import.import_mouse_stepmat(fullfile(mouse_dir_t2,'independent/ntrials_8/stopfood/Pinit025',sprintf('stepmat_nose_L_%g_nstages_8_ntrials_8_Pinit_0.25_indept_stopfood_align_ent.mat',L)),'trial'),...
                 L_values,'UniformOutput',false);

%%

disp('calculating the quantities...')

get_trial_vec  = @(si) double(arrayfun(@(s) s.trial_id,[si.learning_stage.trial]));

trials_ft = get_trial_vec(si_ft{1});
trials_rt = get_trial_vec(si_rt{1});
trials_t1 = get_trial_vec(si_t1{1});
trials_t2 = get_trial_vec(si_t2{1})-trials_t1(end);

[t_food_mat_ft,t_food_err_mat_ft,L_mat_ft,trials_mat_ft] = plot_func.get_tfood_plot_matrices(si_ft,L_values,trials_ft);
[t_food_mat_rt,t_food_err_mat_rt,L_mat_rt,trials_mat_rt] = plot_func.get_tfood_plot_matrices(si_rt,L_values,trials_rt);
[t_food_mat_t1,t_food_err_mat_t1,L_mat_t1,trials_mat_t1] = plot_func.get_tfood_plot_matrices(si_t1,L_values,trials_t1);
[t_food_mat_t2,t_food_err_mat_t2,L_mat_t2,trials_mat_t2] = plot_func.get_tfood_plot_matrices(si_t2,L_values,trials_t2);

%%

disp('fitting individual trials...')

f_ft = func.fit_columns(log(L_mat_ft'),log(t_food_mat_ft'),'poly1');
f_rt = func.fit_columns(log(L_mat_rt'),log(t_food_mat_rt'),'poly1');
f_t1 = func.fit_columns(log(L_mat_t1'),log(t_food_mat_t1'),'poly1');
f_t2 = func.fit_columns(log(L_mat_t2'),log(t_food_mat_t2'),'poly1');

get_slopes = @(fitres) cellfun(@(ff)ff.p1,fitres);

disp('... slopes fixed target')
get_slopes(f_ft)
disp('... slopes relative target')
get_slopes(f_rt)
disp('... slopes 2-target target 1')
get_slopes(f_t1)
disp('... slopes 2-target target 2')
get_slopes(f_t2)

disp('... individual trials have very similar fractal dimension...')

%%

x_fit  = logspace(log10(min(L_values)),log10(max(L_values)),10);
y_func = @(x,a,b) a.*x.^b;

%s = getPlotStruct(x, y, yErr, xLabel, yLabel, xScale, yScale, legendParName, legendParValues, showLegend, plotTitle)
ps = plot_func.getPlotStruct({L_values,L_values,L_values,L_values,x_fit},...
                             {mean(t_food_mat_ft,1),mean(t_food_mat_rt,1),mean(t_food_mat_t1,1),mean(t_food_mat_t2,1),y_func(x_fit,15,1)},...
                             {func.stderr(t_food_mat_ft,1),func.stderr(t_food_mat_rt,1),func.stderr(t_food_mat_t1,1),func.stderr(t_food_mat_t2,1),[]},...
                             'Lattice size, L', 'n_{boxes}', 'log','log','',...
                             {'Random','Static','Target A','Target B','Slope=1'},1);
                         
fig_prop = plot_func.getDefaultFigureProperties();
ppSym = 'osv^n';
ppCol = [204, 34, 34;
         50, 100, 239;
         204, 175, 16;
         249, 216, 49;
         0,0,0]./255;
ppWid = [2,2,2,2,3];
ppLin = {':',':',':',':','-'};

[~,ax,~] = plot_func.plotPlotStruct([], ps, ppLin, ppWid, ppSym, ppCol, ...
        {'MarkerSize', 8, 'MarkerFaceColor', 'auto'},... % plot properties % 'LineWidth', fig_prop.pLineWidth
        {'ShowErrorBar', 'on', 'Color', 'auto', 'Fill', 'on', 'LineStyle', 'none'},... % error properties
        {'Box', 'on', 'Layer', 'top', 'FontSize', 12},... % axis properties
        {'Location', 'northwest', 'FontSize', 9, 'Box', 'off', 'Interpreter', 'tex'},... % legend properties
        {'FontSize', 14,'XDisplacement',[0,-0.05,0]}); % label properties
ax.Position = [0.1300 0.4414 0.5804 0.4836];
ax.XLim = [9,60];

if save_output_figures 
    plot_func.saveFigure(ax.Parent, fullfile(outputDir,'box_size_scaling'), 'png', false, [], 300)
end