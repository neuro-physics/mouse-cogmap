clearvars
close all

track_file = '../experiments/two_target_no_cues/mouse_36/mpos_22Jun2021_trial_Probe2_startloc_NW_day_16.mat';

Tmax            = 60;
show_target     = false;
show_holes      = false;
arena_bg_color  = 'g';
use_real_time   = true;
hole_check_data = load('mouse_36_hole_checks.mat');
fig_prop        = {'Position',[10,10,500,500],'Color','g'};
func.animate_trial(track_file,'mouse_36_hole_check',Tmax,show_target,show_holes,arena_bg_color,use_real_time,hole_check_data,fig_prop);
