import numpy
import modules.io as io
import modules.plot_func as pltt
import modules.traj_analysis as tran
import modules.helper_func_class as misc
#import modules.process_mouse_trials_lib as plib
import matplotlib.pyplot as plt
import scipy.io
import scipy.stats
import os
import datetime
import time
#import matplotlib.image as mpimg

def main():
    """

    THE SUFFIXES IN THE VARIABLE NAMES

    *** rt suffix -> relative target experiments
                    this means STATIC entrance,
                    since the target is always
                    positioned in the same spot
                    relative to the entrance
                    the mouse takes

    *** ft suffix -> fixed target experiments
                    this means RANDOM entrance,
                    since the target is in a
                    different spot in every trial,
                    relative to the entrance the mouse
                    takes

    *** tt suffix -> two target experiments
                    mice are trained in two locations, consecutively

    """

    mouse_traj_dir_ft = r'./experiments/fixed_target/mouse_*'
    #mouse_traj_dir_ft = [ r'./experiments/fixed_target/mouse_37',
    #                      r'./experiments/fixed_target/mouse_38',
    #                      r'./experiments/fixed_target/mouse_39',
    #                      r'./experiments/fixed_target/mouse_40',
    #                      r'./experiments/fixed_target/mouse_53',
    #                      r'./experiments/fixed_target/mouse_54',
    #                      r'./experiments/fixed_target/mouse_55',
    #                      r'./experiments/fixed_target/mouse_56' ]

    n_trials_ft = 18

    mouse_traj_dir_rt = r'./experiments/relative_target/mouse_*'
    #mouse_traj_dir_rt = [ r'./experiments/relative_target/mouse_9',
    #                      r'./experiments/relative_target/mouse_10',
    #                      r'./experiments/relative_target/mouse_11',
    #                      r'./experiments/relative_target/mouse_12',
    #                      r'./experiments/relative_target/mouse_13',
    #                      r'./experiments/relative_target/mouse_14',
    #                      r'./experiments/relative_target/mouse_15',
    #                      r'./experiments/relative_target/mouse_16' ]
    n_trials_rt = 14

    n_trials = numpy.min((n_trials_ft,n_trials_rt))

    mouse_part = 'center'

    output_dir = 'experiments'
    try:
        os.makedirs(output_dir)
    except FileExistsError:
        pass

    # loads experiment MAT files from file path according to the parameters
    #
    # load_only_training_sessions -> if True, skips all rotated trials (RXXX_Y trials), loads only standard 1 to 17 or 1 to 14 trials
    # skip_15 -> if True, skips trial 15 (since it was a probe trial without food)
    # use_extra_trials -> if True, returns all 1 to 17 trials (15 is treated according to parameter above); otherwise returns from 1 to 14
    # sort_by_trial -> if True, then the return list of files is sorted according to the trial number
    #
    # each loaded data file then goes through the fill_trajectory_nan_gaps function
    # where the r_nose, r_center and r_tail are linearly interpolated over the missing data intervals (nan gaps)
    # and the velocity is assumed constant over these gap intervals (since the position is linear with time)
    # this interpolation of r and v is important because you want to calculate the mouse vector and velocity thresholds over all the recording time
    #
    # all_trials[0] -> all files of first trial (0 indexed); all_trials[1] -> all files of second trial; etc
    # all_trials[0][0] -> file of mouse 9 of trial 0; all_trials[0][1] -> mouse 10 (2nd mouse) in trial 0 (1st trial); etc

    slow_down_frac = 0.4

    print('*** calculating self-intersections of the whole trajectory')
    all_trials_rt,trial_labels_rt=io.load_trial_file(mouse_traj_dir_rt,load_only_training_sessions_relative_target=True,skip_15_relative_target=True,use_extra_trials_relative_target=False,sort_by_trial=True,fix_nan=True,remove_after_food=True,align_to_top=True,group_by='trial',return_group_by_keys=True)
    all_trials_ft,trial_labels_ft=io.load_trial_file(mouse_traj_dir_ft,load_only_training_sessions_relative_target=True,skip_15_relative_target=False,use_extra_trials_relative_target=True,sort_by_trial=True,fix_nan=True,remove_after_food=True,align_to_top=True,group_by='trial',return_group_by_keys=True)
    all_trials_rt = tran.remove_slow_parts(all_trials_rt,threshold_method='ampv',gamma=slow_down_frac,return_threshold=False, copy_track=False)
    all_trials_ft = tran.remove_slow_parts(all_trials_ft,threshold_method='ampv',gamma=slow_down_frac,return_threshold=False, copy_track=False)
    output_filename = f'self_intersection_fixtgt_reltgt_vth{slow_down_frac}'
    tran.calc_self_intersections(all_trials_rt,trial_labels_rt,all_trials_ft,trial_labels_ft,output_dir,output_filename=output_filename,mouse_part=mouse_part,save_data=True)

    print('*** calculating self-intersections of 1st half of the trajectory')
    all_trials_rt,trial_labels_rt=io.load_trial_file(mouse_traj_dir_rt,load_only_training_sessions_relative_target=True,skip_15_relative_target=True,use_extra_trials_relative_target=False,sort_by_trial=True,fix_nan=True,remove_after_food=True,align_to_top=True,group_by='trial',return_group_by_keys=True,t0_frac=0.0,dt_frac=0.5)
    all_trials_ft,trial_labels_ft=io.load_trial_file(mouse_traj_dir_ft,load_only_training_sessions_relative_target=True,skip_15_relative_target=False,use_extra_trials_relative_target=True,sort_by_trial=True,fix_nan=True,remove_after_food=True,align_to_top=True,group_by='trial',return_group_by_keys=True,t0_frac=0.0,dt_frac=0.5)
    all_trials_rt = tran.remove_slow_parts(all_trials_rt,threshold_method='ampv',gamma=slow_down_frac,return_threshold=False, copy_track=False)
    all_trials_ft = tran.remove_slow_parts(all_trials_ft,threshold_method='ampv',gamma=slow_down_frac,return_threshold=False, copy_track=False)
    output_filename = f'self_intersection_fixtgt_reltgt_vth{slow_down_frac}_1st_half'
    tran.calc_self_intersections(all_trials_rt,trial_labels_rt,all_trials_ft,trial_labels_ft,output_dir,output_filename=output_filename,mouse_part=mouse_part,save_data=True)

    print('*** calculating self-intersections of 2nd half of the trajectory')
    all_trials_rt,trial_labels_rt=io.load_trial_file(mouse_traj_dir_rt,load_only_training_sessions_relative_target=True,skip_15_relative_target=True,use_extra_trials_relative_target=False,sort_by_trial=True,fix_nan=True,remove_after_food=True,align_to_top=True,group_by='trial',return_group_by_keys=True,t0_frac=0.5,dt_frac=0.5)
    all_trials_ft,trial_labels_ft=io.load_trial_file(mouse_traj_dir_ft,load_only_training_sessions_relative_target=True,skip_15_relative_target=False,use_extra_trials_relative_target=True,sort_by_trial=True,fix_nan=True,remove_after_food=True,align_to_top=True,group_by='trial',return_group_by_keys=True,t0_frac=0.5,dt_frac=0.5)
    all_trials_rt = tran.remove_slow_parts(all_trials_rt,threshold_method='ampv',gamma=slow_down_frac,return_threshold=False, copy_track=False)
    all_trials_ft = tran.remove_slow_parts(all_trials_ft,threshold_method='ampv',gamma=slow_down_frac,return_threshold=False, copy_track=False)
    output_filename = f'self_intersection_fixtgt_reltgt_vth{slow_down_frac}_2nd_half'
    tran.calc_self_intersections(all_trials_rt,trial_labels_rt,all_trials_ft,trial_labels_ft,output_dir,output_filename=output_filename,mouse_part=mouse_part,save_data=True)

if __name__ == '__main__':
    main()