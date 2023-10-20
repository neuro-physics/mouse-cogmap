clearvars
close all

set(0, 'defaulttextfontname', 'Arial')
set(0, 'defaultaxesfontname', 'Arial')

mouse_dir_ft          = '../step_prob_matrices/fixed_target_jackknife';
mouse_dir_rt          = '../step_prob_matrices/relative_target_jackknife';
mouse_dir_l1          = '../step_prob_matrices/two_target_no_cues_tgt1_jackknife_typical_mice';
mouse_dir_l2          = '../step_prob_matrices/two_target_no_cues_tgt2_jackknife_typical_mice';
mouse_dir_p2          = '../step_prob_matrices/two_target_no_cues_probe2_A-B_jackknife_typical_mice';
%mouse_dir_p2_complete = '../step_prob_matrices/two_target_no_cues_probe2_typical_mice';

outputDir    = '../figs/paper/step_prob_typical_mouse';

if exist(outputDir,'dir') ~= 7
    mkdir(outputDir);
end

save_output_figures = true;

use_grid_visits_as_color = false;
force_cumulative_prob    = false;
nPanel                   = 4;
mouse_idx                = [];
L                        = 11; % 51;

% loading experimental data

input_files_ft = fullfile(mouse_dir_ft,'independent/ntrials_14/stopfood/Pinit025',sprintf('stepmat_nose_L_%g_nstages_14_ntrials_14_Pinit_0.25_indept_stopfood_align_tgt.mat',L));
input_files_rt = fullfile(mouse_dir_rt,'independent/ntrials_14/stopfood/Pinit025',sprintf('stepmat_nose_L_%g_nstages_14_ntrials_14_Pinit_0.25_indept_stopfood_align_ent.mat',L));
input_files_l1 = fullfile(mouse_dir_l1,'independent/ntrials_18/stopfood/Pinit025',sprintf('stepmat_nose_L_%g_nstages_18_ntrials_18_Pinit_0.25_indept_stopfood_align_ent.mat',L));
input_files_l2 = fullfile(mouse_dir_l2,'independent/ntrials_8/stopfood/Pinit025' ,sprintf('stepmat_nose_L_%g_nstages_8_ntrials_8_Pinit_0.25_indept_stopfood_align_ent.mat',L))  ;
input_files_p2 = fullfile(mouse_dir_p2,'independent/ntrials_1/stopfood/Pinit025' ,sprintf('stepmat_nose_L_%g_nstages_1_ntrials_1_Pinit_0.25_indept_stopfood_align_ent.mat',L))  ;
%input_files_p2_complete = fullfile(mouse_dir_p2_complete,'independent/ntrials_1/stopfood/Pinit025' ,sprintf('stepmat_nose_L_%g_nstages_1_ntrials_1_Pinit_0.25_indept_stopfood_align_ent.mat',L))  ;


d = load(input_files_ft);
dr_target_correction = cellfun(@(x)func.inline_if(all(x==[6,6]),ones(1,2),zeros(1,2)),d.r_target_trial,'UniformOutput',false);

all_trials_ft = import.import_mouse_stepmat(input_files_ft,'mouse',[],dr_target_correction);
all_trials_rt = import.import_mouse_stepmat(input_files_rt,'mouse');
all_trials_l1 = import.import_mouse_stepmat(input_files_l1,'mouse',[1,1]);
all_trials_l2 = import.import_mouse_stepmat(input_files_l2,'mouse');
all_trials_p2 = import.import_mouse_stepmat(input_files_p2,'mouse');
%all_trials_p2_complete = import.import_mouse_stepmat(input_files_p2_complete,'mouse');

G1_l1       = arena.calc_prob_gradient_with_positions(all_trials_l1.sites_per_stage{1},all_trials_l1.simParam.L,true);
G2_l1       = arena.calc_prob_gradient_with_positions(all_trials_l1.sites_per_stage{14},all_trials_l1.simParam.L,true);
G1_l2       = arena.calc_prob_gradient_with_positions(all_trials_l2.sites_per_stage{1},all_trials_l2.simParam.L,true);
G2_l2       = arena.calc_prob_gradient_with_positions(all_trials_l2.sites_per_stage{8},all_trials_l2.simParam.L,true);
G1_p2       = arena.calc_prob_gradient_with_positions(all_trials_p2.sites_per_stage{1},all_trials_p2.simParam.L,true);
G1_p2_compl = G1_p2       ;
%G1_p2_compl = arena.calc_prob_gradient_with_positions(all_trials_p2_complete.sites_per_stage{1},all_trials_p2_complete.simParam.L,true);

dist_AB            = 9; % distance between A and B targets in lattice coordinates
n_bootstrp_samples = 10;

G            = { G1_l1,     G2_l1,        G1_l2,      G2_l2,        G1_p2,      G1_p2_compl};
trial_labels = {'Trial 1-A','Trial 14-A','Trial 1-B', 'Trial 8-B', 'Probe A-B', 'Random Probe A-B'};


L = all_trials_l1.simParam.L(1);
max_steps = 4.*(L.^2-L);

%%

calc_percent_displacement = @(step_vec) 100.*sum(step_vec,1)./max_steps;
bootstrap_displacement    = @(nboot_samples,step_vec) bootstrp(nboot_samples,calc_percent_displacement,step_vec);
calc_displacement_norm    = @(step_vec) vecnorm(step_vec,2,2);

sample_step_displacement  = cellfun(@(GG)calc_displacement_norm(bootstrap_displacement(n_bootstrp_samples,GG)),G(1:end-1),'UniformOutput',false); % we take stddev over a bootstrap sample of the step vectors
step_displacement         = cellfun(@(GG)calc_displacement_norm(calc_percent_displacement(GG)),G(1:end-1));
step_displacement_std     = cellfun(@(GG)std(GG),sample_step_displacement); % we take stddev over a bootstrap sample of the step vectors

% calc step displacement for randomized Probe2
G_p2_random                     = func.random_rows_sample(G1_p2_compl,dist_AB,n_bootstrp_samples);
sample_step_displacement{end+1} = cellfun(@(GG)calc_displacement_norm(calc_percent_displacement(GG)),G_p2_random)';
step_displacement(end+1)        = mean(sample_step_displacement{end});
step_displacement_std(end+1)    = std(sample_step_displacement{end});

README = 'The variables contain: sample_step_displacement -> bootstrap samples for the step displacement of each trial; step_displacement -> true total percentual displacement of each trial; step_displacement_std -> bootstrap stddev of total percentual displacement of each trial; trial_labels -> label that correspond to each entry in each of the displacement variables; L -> lattice size used to calculate the gradients; max_steps -> 4(L^2-L) is the total number of allowed steps in a lattice of lateral size L; dist_AB -> lattice distance between A and B targets';
fprintf([strrep(strrep(README,';',';\n'),':',':\n\n'),'\n']);
save('../step_prob_matrices/step_gradient_displacement_boxplot_data.mat','sample_step_displacement','step_displacement','step_displacement_std','trial_labels','README','L','max_steps','dist_AB');