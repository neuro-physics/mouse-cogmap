# this script, together with the lib process_mouse_trials_lib
# is used to process the raw excel files that have the tracking
# of the mouse in the arena looking for the hidden food
#
# the experiments were originally performed by Kelly Xu from Len Maler lab
#
# the original excel files are not going to be included in this repository
#
# instead, we provide only the processed files (in .mat format)
# that contain all the relevant information for the trajectories
# extracted from the excel files...
#
# this script generates the step probability matrices from the mice trajectories

import os
import copy
import numpy
import modules.io as io
import modules.traj_analysis as tran
import modules.helper_func_class as misc
import modules.traj_to_step_matrix as tstep
import modules.process_mouse_trials_lib as plib

def main():
    """
    # step matrices will be calculated for each combination of parameters below,
    # n_stages will also contain the total number of trials (such that there's one trial per stage only)
    # n_stages == n_trials_total is automatically added to the simulation
    # later on inside the run_configurations function
    """
    clear_output_directory = True
    #out_dir_suffix         = ''
    #config_param           = dict(mouse_part           = ['nose'],
    #                              L                    = [11,21,31,41,51],
    #                              prob_calc            = [misc.ProbabilityType.cumulative_prob,misc.ProbabilityType.cumulative_step,misc.ProbabilityType.independent],
    #                              start_from_zero      = [False],
    #                              n_stages             = [],
    #                              stop_at_food         = [True] )
    out_dir_suffix         = 'jackknife'
    config_param           = dict(mouse_part           = ['nose'],
                                  L                    = [11],
                                  prob_calc            = [misc.ProbabilityType.independent],
                                  start_from_zero      = [False],
                                  n_stages             = [],
                                  stop_at_food         = [True] )
    config_param_1stage    = dict(mouse_part           = ['nose'],
                                  L                    = [11,51],
                                  prob_calc            = [misc.ProbabilityType.independent],
                                  start_from_zero      = [False],
                                  n_stages             = [1],
                                  stop_at_food         = [True] )

    """
    each key below contains a dict where key = trial number (as str), value = list with mouse numbers to omit for step map calculation
    """
    omit_mice = dict(
        relative_target             = dict() ,
        fixed_target                = dict() ,
        fixed_target_entrance       = dict() ,
        two_targets                 = {'16'    : [35]       ,
                                       '26'    : [33,35]    } , # trial '16' is 16-A # trial '26' is equivalent to 8-B (last training trial of target B)
        two_targets1                = {'16'    : [35]       } , # trial '16' is 16-A
        two_targets2                = {'26'    : [33,35]    } , # trial '26' is equivalent to 8-B (last training trial of target B)
        two_targets_probe2          = {'Probe2': [34,58,60] } ,
        two_targets_probe3          = dict(),
        relative_target_R180        = dict(),
        two_targets_rot_all1        = dict(),
        two_targets_rot_all2        = dict(),
        two_targets_rot_all_probe2  = {'Probe2': [2,4,5,6,7,73,74,75]}
    )

    """
    #
    #  comment out the experiments you DON'T WANT to run
    # 
    """

    """ main paper calculations """
    #run_configurations('relative_target'       , clear_output_directory, omit_mice=None     , force_calc_separate_trials=True , out_dir_suffix=out_dir_suffix   , **config_param)
    #run_configurations('fixed_target'          , clear_output_directory, omit_mice=None     , force_calc_separate_trials=True , out_dir_suffix=out_dir_suffix   , **config_param)
    #run_configurations('two_targets'           , clear_output_directory, omit_mice=omit_mice, force_calc_separate_trials=True , out_dir_suffix=out_dir_suffix   , **config_param)
    #run_configurations('two_targets1'          , clear_output_directory, omit_mice=omit_mice, force_calc_separate_trials=True , out_dir_suffix=out_dir_suffix   , **config_param)
    #run_configurations('two_targets2'          , clear_output_directory, omit_mice=omit_mice, force_calc_separate_trials=True , out_dir_suffix=out_dir_suffix   , **config_param)
    #run_configurations('two_targets_probe2'    , clear_output_directory, omit_mice=omit_mice, force_calc_separate_trials=True , out_dir_suffix=out_dir_suffix   , **config_param)
    #run_configurations('two_targets_probe2'    , clear_output_directory, omit_mice=omit_mice, force_calc_separate_trials=True , out_dir_suffix=out_dir_suffix   , keep_between_targets=True, **config_param)

    #run_configurations('relative_target_R180'       , clear_output_directory, omit_mice=None , force_calc_separate_trials=True , out_dir_suffix=out_dir_suffix   , **config_param)
    #run_configurations('two_targets_rot_all1'       , clear_output_directory, omit_mice=None , force_calc_separate_trials=True , out_dir_suffix=out_dir_suffix   , **config_param)
    #run_configurations('two_targets_rot_all2'       , clear_output_directory, omit_mice=None , force_calc_separate_trials=True , out_dir_suffix=out_dir_suffix   , **config_param)
    run_configurations('two_targets_rot_all_probe2' , clear_output_directory, omit_mice=omit_mice , force_calc_separate_trials=True , out_dir_suffix=out_dir_suffix   , keep_between_targets=True, **config_param)

    
    #run_configurations('fixed_target_entrance' , clear_output_directory, omit_mice=None     , force_calc_separate_trials=True , out_dir_suffix=out_dir_suffix   , **config_param)
    #run_configurations('two_targets'           , clear_output_directory, omit_mice=None     , force_calc_separate_trials=True , out_dir_suffix=out_dir_suffix   , **config_param)
    #run_configurations('two_targets1'          , clear_output_directory, omit_mice=None     , force_calc_separate_trials=True , out_dir_suffix=out_dir_suffix   , **config_param)
    #run_configurations('two_targets2'          , clear_output_directory, omit_mice=None     , force_calc_separate_trials=True , out_dir_suffix=out_dir_suffix   , **config_param)
    #run_configurations('two_targets_probe2'    , clear_output_directory, omit_mice=None     , force_calc_separate_trials=True , out_dir_suffix=out_dir_suffix   , **config_param)
    #run_configurations('two_targets_probe3'    , clear_output_directory, omit_mice=None     , force_calc_separate_trials=True , out_dir_suffix=out_dir_suffix   , **config_param)
    #run_configurations('two_targets_probe2'    , clear_output_directory, omit_mice=None     , force_calc_separate_trials=True , out_dir_suffix=out_dir_suffix   , keep_between_targets=True, **config_param)
    #run_configurations('two_targets_probe3'    , clear_output_directory, omit_mice=None     , force_calc_separate_trials=True , out_dir_suffix=out_dir_suffix   , keep_between_targets=True, **config_param)

    #run_configurations('relative_target'       , clear_output_directory, omit_mice=None     , force_calc_separate_trials=False, out_dir_suffix='1stage'+out_dir_suffix , **config_param_1stage)
    #run_configurations('fixed_target'          , clear_output_directory, omit_mice=None     , force_calc_separate_trials=False, out_dir_suffix='1stage'+out_dir_suffix , **config_param_1stage)
    #run_configurations('fixed_target_entrance' , clear_output_directory, omit_mice=None     , force_calc_separate_trials=False, out_dir_suffix='1stage'+out_dir_suffix , **config_param_1stage)
    #run_configurations('two_targets'           , clear_output_directory, omit_mice=None     , force_calc_separate_trials=False, out_dir_suffix='1stage'+out_dir_suffix , **config_param_1stage)
    #run_configurations('two_targets1'          , clear_output_directory, omit_mice=None     , force_calc_separate_trials=False, out_dir_suffix='1stage'+out_dir_suffix , **config_param_1stage)
    #run_configurations('two_targets2'          , clear_output_directory, omit_mice=None     , force_calc_separate_trials=False, out_dir_suffix='1stage'+out_dir_suffix , **config_param_1stage)
    #run_configurations('two_targets'           , clear_output_directory, omit_mice=omit_mice, force_calc_separate_trials=False, out_dir_suffix='1stage'+out_dir_suffix , **config_param_1stage)
    #run_configurations('two_targets1'          , clear_output_directory, omit_mice=omit_mice, force_calc_separate_trials=False, out_dir_suffix='1stage'+out_dir_suffix , **config_param_1stage)
    #run_configurations('two_targets2'          , clear_output_directory, omit_mice=omit_mice, force_calc_separate_trials=False, out_dir_suffix='1stage'+out_dir_suffix , **config_param_1stage)

def remove_mice_from_trials(input_tracks_experiment,omit_mice_experiment):
    """
    removes the given mouse number from the given trials (both given in omit_mice dict)
    input_tracks -> list of input trackfile's
    omit_mice    -> dict   :: key   -> trial number (plib.trial_to_number result)
                           :: value -> list of mice to omit in the given trial
                    dict containing the list of mice to skip in each trial (if any)
    returns
        a filteres list of input_tracks
    """
    has_mice_to_skip = misc.exists(omit_mice_experiment) and (len(omit_mice_experiment) > 0)
    if not has_mice_to_skip:
        return input_tracks_experiment
    omit_mice_experiment = { plib.trial_to_number(trial):[ int(mouse) for mouse in mice ] for trial,mice in omit_mice_experiment.items() } # making sure the trials and the mouse numbers are numbers
    do_omit_track        = lambda track: (plib.trial_to_number(track.trial) in omit_mice_experiment.keys()) and (int(track.mouse_number) in omit_mice_experiment[plib.trial_to_number(track.trial)])
    return [ tr for tr in input_tracks_experiment if not do_omit_track(tr) ]

def run_configurations(experiment,clear_output_directory,out_dir_suffix='',omit_mice=None,force_calc_separate_trials=False,keep_between_targets=False,mouse_part=None,L=None,prob_calc=None,start_from_zero=None,n_stages=None,stop_at_food=None):
    """
    experiment                 -> experiment label we want to calculate the step maps for
    clear_output_directory     -> delete all files in output dir before running simulations
    out_dir_suffix             -> suffix to be added to the output directory
    omit_mice                  -> { 'trial#': [mouse number list], ... } 
                                  omit mice dict (see docs above in the main function and in the remove_mice_from_trials func);
    force_calc_separate_trials -> if True, then forces running the simulation for each trial separately
    keep_between_targets       -> 2-target, where we only calculate between the target and target_alt (good for the probe trial)

    this function then runs a simulation for each combination of the parameters in the lists given by the arguments below:
    see function traj_to_step_matrix.get_calc_step_probability_param_struct
    for more detail documentation
    mouse_part      -> list of mouse parts to use for each simulation (nose is recommended)
    L               -> list of lattice sizes where to run the simulation
    prob_calc       -> list of misc.ProbabilityType tells the simulation how to accumulate step probabilities across trials
    start_from_zero -> list containing True/False flags to decide whether the initial step probability is 0 (True) or 1/4 (False)
    n_stages        -> list of the number of stages where we want to run a simulation (if n_stage < n_trial_total, then each stage is composed of n_trial_total/n_stage trials, approximately)
    stop_at_food    -> list containing True/False flags to decided whether the sim stops counting steps when find the food
    """
    valid_experiments = [
        'relative_target'           ,
        'fixed_target'              ,
        'fixed_target_entrance'     ,
        'two_targets'               ,
        'two_targets1'              ,
        'two_targets2'              ,
        'two_targets_probe2'        ,
        'two_targets_probe3'        ,
        'relative_target_R180'      ,
        'two_targets_rot_all1'      ,
        'two_targets_rot_all2'      ,
        'two_targets_rot_all_probe2']
    assert experiment in valid_experiments, "experiment must be one of: %s"%(str(valid_experiments)[1:-1].replace("'",""))
    """
    ################################
    ################################
    ################################
    ################################ input/output configuration
    ################################
    ################################
    ################################
    """

    print(' ########################## ')
    print(' ########################## ')
    print(' ###  ')
    print(' ### CALCULATING FOR EXPERIMENT %s '%experiment)
    print(' ###  ')
    print(' ########################## ')
    print(' ########################## ')


    if experiment == 'relative_target':
        mouse_traj_dir     = r'./experiments/relative_target/mouse_*'
        out_dir            = r'step_prob_matrices/relative_target'
        n_trials_to_use    = 14
        input_tracks       = io.load_trial_file(mouse_traj_dir,load_only_training_sessions_relative_target=True,skip_15_relative_target=True,use_extra_trials_relative_target=False,sort_by_trial=True,fix_nan=True,remove_after_food=stop_at_food,group_by='none',max_trial_number=n_trials_to_use)
        use_extra_trials   = [False]
        align_method       = ['entrance'] # 'entrance' or 'target'
        use_latest_target  = [False]
        use_reverse_target = [False]

    elif experiment == 'relative_target_R180':
        mouse_traj_dir     = r'./experiments/relative_target/mouse_*'
        out_dir            = r'step_prob_matrices/relative_target_R180'
        filename_expr      = 'mpos_*_R180_1*'
        #n_trials_to_use   = 14
        hole_horizon       = 5.0 # cm
        get_hole_horiz     = lambda tr: hole_horizon if int(tr.mouse_number) in [14,16] else None # 5 cm for mouse 16 and 14; otherwise None is ok
        input_tracks       = io.load_trial_file(mouse_traj_dir,file_name_expr=filename_expr,load_only_training_sessions_relative_target=False,skip_15_relative_target=True,use_extra_trials_relative_target=True,sort_by_trial=True,fix_nan=True,remove_after_food=False,group_by='none')#,max_trial_number=n_trials_to_use)
        if stop_at_food:
            input_tracks   = [ tran.remove_path_after_food(tr,r_target=tr.r_target_reverse,return_t_to_food=False,force_main_target=False,hole_horizon=get_hole_horiz(tr),time_delay_after_food=0.0) for tr in input_tracks ]
        use_extra_trials   = [False]
        align_method       = ['entrance'] # 'entrance' or 'target'
        use_latest_target  = [False]
        use_reverse_target = [True]

    elif experiment == 'fixed_target':
        mouse_traj_dir     = r'./experiments/fixed_target/mouse_*'
        out_dir            = r'step_prob_matrices/fixed_target'
        n_trials_to_use    = 14
        input_tracks       = io.load_trial_file(mouse_traj_dir,load_only_training_sessions_relative_target=True,skip_15_relative_target=False,use_extra_trials_relative_target=True,sort_by_trial=True,fix_nan=True,remove_after_food=stop_at_food,group_by='none',max_trial_number=n_trials_to_use)
        use_extra_trials   = [True]
        align_method       = ['target_trial_consistent'] # 'entrance' or 'target'
        use_latest_target  = [False]
        use_reverse_target = [False]
    
    elif experiment == 'fixed_target_entrance':
        mouse_traj_dir     = r'./experiments/fixed_target/mouse_*'
        out_dir            = r'step_prob_matrices/fixed_target_entrance_align'
        n_trials_to_use    = 14
        input_tracks       = io.load_trial_file(mouse_traj_dir,load_only_training_sessions_relative_target=True,skip_15_relative_target=False,use_extra_trials_relative_target=True,sort_by_trial=True,fix_nan=True,remove_after_food=stop_at_food,group_by='none',max_trial_number=n_trials_to_use)
        use_extra_trials   = [True]
        align_method       = ['entrance'] # 'entrance' or 'target'
        use_latest_target  = [False]
        use_reverse_target = [False]

    elif experiment == 'two_targets1':
        # loading all training trials for target 1
        # all_trials_l1[k][m] -> trial k of mouse m
        mouse_traj_dir     = r'./experiments/two_target_no_cues/mouse_*'
        out_dir            = r'step_prob_matrices/two_target_no_cues_tgt1'
        n_trials_l1        = 18
        input_tracks       = io.load_trial_file(mouse_traj_dir, load_only_training_sessions_relative_target=True, fix_nan=True, sort_by_trial=True, group_by='none',return_group_by_keys=False,remove_after_food=False,max_trial_number=n_trials_l1)
        if stop_at_food:
            input_tracks   = tran.remove_path_after_food(input_tracks,r_target=None,return_t_to_food=False,force_main_target=True,hole_horizon=None,time_delay_after_food=0.0)
        use_extra_trials   = [True]
        align_method       = ['entrance'] # 'entrance' or 'target'
        use_latest_target  = [False]
        use_reverse_target = [False]

    elif experiment == 'two_targets2':
        # loading all training trials for target 2 (after target 1)
        # all_trials_l2[k][m] -> trial k of mouse m
        mouse_traj_dir     = r'./experiments/two_target_no_cues/mouse_*'
        out_dir            = r'step_prob_matrices/two_target_no_cues_tgt2'
        n_trials_l1        = 18
        nmax_trials_l2     = 26
        input_tracks       = [ tr for tr in io.load_trial_file(mouse_traj_dir, load_only_training_sessions_relative_target=True, fix_nan=True, sort_by_trial=True, group_by='none',return_group_by_keys=False,remove_after_food=False,max_trial_number=nmax_trials_l2) if ((int(tr.trial)>n_trials_l1) and (int(tr.trial)<=nmax_trials_l2)) ]
        if stop_at_food:
            input_tracks   = tran.remove_path_after_food(input_tracks,r_target=None,return_t_to_food=False,force_main_target=True,hole_horizon=None,time_delay_after_food=0.0)
        use_extra_trials   = [True]
        align_method       = ['entrance'] # 'entrance' or 'target'
        use_latest_target  = [False]
        use_reverse_target = [False]

    elif experiment == 'two_targets':
        mouse_traj_dir     = r'./experiments/two_target_no_cues/mouse_*'
        out_dir            = r'step_prob_matrices/two_target_no_cues'
        nmax_trials_l2     = 26
        input_tracks       = io.load_trial_file(mouse_traj_dir, load_only_training_sessions_relative_target=True, fix_nan=True, sort_by_trial=True, group_by='none',return_group_by_keys=False,remove_after_food=False)
        input_tracks       = tran.remove_path_after_food(input_tracks,r_target=None,return_t_to_food=False,force_main_target=True,hole_horizon=None,time_delay_after_food=0.0)
        use_extra_trials   = [True]
        align_method       = ['entrance'] # 'entrance' or 'target'
        use_latest_target  = [False]
        use_reverse_target = [False]
    
    elif experiment in ['two_targets_probe2','two_targets_probe3']:
        filename_expr          = 'mpos_*Probe2_*' if experiment == 'two_targets_probe2' else 'mpos_*Probe3_*'
        out_dirname_suffix     = '_A-B' if keep_between_targets else ''
        hole_horizon           = 10.0 # cm
        time_delay_after_food  = 1.0 # sec
        mouse_traj_dir         = r'./experiments/two_target_no_cues/mouse_*'
        out_dir                = r'step_prob_matrices/two_target_no_cues_probe' + experiment[-1] + out_dirname_suffix
        input_tracks           = io.load_trial_file(mouse_traj_dir,file_name_expr=filename_expr,align_to_top=True,fix_nan=True,sort_by_trial=True,return_group_by_keys=False,remove_after_food=False)
        if keep_between_targets:
            input_tracks       = tran.keep_path_between_targets(input_tracks,return_t_in_targets=False,hole_horizon=hole_horizon,time_delay_after_food=time_delay_after_food,copy_tracks=True)
        elif stop_at_food:
            input_tracks       = tran.remove_path_after_food(input_tracks,force_main_target=False,return_t_to_food=False,hole_horizon=hole_horizon,time_delay_after_food=time_delay_after_food,copy_tracks=True)
        use_extra_trials       = [True]
        align_method           = ['entrance'] # 'entrance' or 'target'
        use_latest_target      = [True]
        use_reverse_target     = [False]
    elif experiment == 'two_targets_rot_all1':
        # loading all training trials for target 1
        # all_trials_l1[k][m] -> trial k of mouse m
        mouse_traj_dir     = [r'./experiments/two_targets_rot/mouse_*'       ,
                              r'./experiments/two_targets_rot_fem/mouse_*'   ,
                              r'./experiments/two_targets_rot_mixsex/mouse_*']
        out_dir            = r'step_prob_matrices/two_targets_rot_all_tgt1'
        n_trials_l1        = 18
        input_tracks       = io.load_trial_file(mouse_traj_dir, load_only_training_sessions_relative_target=True, fix_nan=True, sort_by_trial=True, group_by='none',return_group_by_keys=False,remove_after_food=False,max_trial_number=n_trials_l1)
        if stop_at_food:
            input_tracks   = tran.remove_path_after_food(input_tracks,r_target=None,return_t_to_food=False,force_main_target=True,hole_horizon=None,time_delay_after_food=0.0)
        use_extra_trials   = [True]
        align_method       = ['entrance'] # 'entrance' or 'target'
        use_latest_target  = [False]
        use_reverse_target = [False]

    elif experiment == 'two_targets_rot_all2':
        # loading all training trials for target 2 (after target 1)
        # all_trials_l2[k][m] -> trial k of mouse m
        mouse_traj_dir     = [r'./experiments/two_targets_rot/mouse_*'       ,
                              r'./experiments/two_targets_rot_fem/mouse_*'   ,
                              r'./experiments/two_targets_rot_mixsex/mouse_*']
        out_dir            = r'step_prob_matrices/two_targets_rot_all_tgt2'
        n_trials_l1        = 18
        nmax_trials_l2     = 26
        input_tracks       = [ tr for tr in io.load_trial_file(mouse_traj_dir, load_only_training_sessions_relative_target=True, fix_nan=True, sort_by_trial=True, group_by='none',return_group_by_keys=False,remove_after_food=False,max_trial_number=nmax_trials_l2) if ((int(tr.trial)>n_trials_l1) and (int(tr.trial)<=nmax_trials_l2)) ]
        if stop_at_food:
            input_tracks   = tran.remove_path_after_food(input_tracks,r_target=None,return_t_to_food=False,force_main_target=True,hole_horizon=None,time_delay_after_food=0.0)
        use_extra_trials   = [True]
        align_method       = ['entrance'] # 'entrance' or 'target'
        use_latest_target  = [False]
        use_reverse_target = [False]

    elif experiment == 'two_targets_rot_all_probe2':
        filename_expr1         = 'mpos_*Probe2_*'
        filename_expr2         = 'mpos_*Probe_2_*'
        out_dirname_suffix     = '_A-B' if keep_between_targets else ''
        hole_horizon           = 10.0 # cm
        time_delay_after_food  = 1.0 # sec
        mouse_traj_dir         = [r'./experiments/two_targets_rot/mouse_*'       ,
                                  r'./experiments/two_targets_rot_fem/mouse_*'   ,
                                  r'./experiments/two_targets_rot_mixsex/mouse_*']
        out_dir                = r'step_prob_matrices/two_targets_rot_all_probe2' + out_dirname_suffix
        input_tracks           = misc.flatten_list([
                                        io.load_trial_file(mouse_traj_dir,file_name_expr=filename_expr1,align_to_top=True,fix_nan=True,sort_by_trial=True,return_group_by_keys=False,remove_after_food=False),
                                        io.load_trial_file(mouse_traj_dir,file_name_expr=filename_expr2,align_to_top=True,fix_nan=True,sort_by_trial=True,return_group_by_keys=False,remove_after_food=False),
                                    ], only_lists=True, return_list=True)
        if keep_between_targets:
            input_tracks       = tran.keep_path_between_targets(input_tracks,return_t_in_targets=False,hole_horizon=hole_horizon,time_delay_after_food=time_delay_after_food,copy_tracks=True)
        elif stop_at_food:
            input_tracks       = tran.remove_path_after_food(input_tracks,force_main_target=False,return_t_to_food=False,hole_horizon=hole_horizon,time_delay_after_food=time_delay_after_food,copy_tracks=True)
        use_extra_trials       = [True]
        align_method           = ['entrance'] # 'entrance' or 'target'
        use_latest_target      = [True]
        use_reverse_target     = [False]

    else:
        raise ValueError('invalid experiment')

    if len(out_dir_suffix) > 0:
        out_dir += '_' + out_dir_suffix

    omit_mice_if_needed = lambda x: x
    if misc.exists(omit_mice) and (len(omit_mice[experiment])>0):
        out_dir += '_typical_mice'
        omit_mice_if_needed = lambda x: remove_mice_from_trials(x,omit_mice[experiment])

    """
    ################################
    ################################
    ################################
    ################################ probability matrix calculations
    ################################
    ################################
    ################################
    """

    # filtering tracks
    #if n_trials_to_use:
    #    input_tracks = [ tr for tr in input_tracks if plib.trial_to_number(tr.trial) <= n_trials_to_use ]

    os.makedirs(out_dir,exist_ok=True)
    if clear_output_directory:
        io.clear_directory(out_dir,verbose=True)



    # settings that we want to simulate
    # (we will calculate the matrices for each combination of the parameters below)
    mouse_part      = mouse_part      if misc.exists(mouse_part      ) else ['nose']
    L               = L               if misc.exists(L               ) else [11,21,31,41,51]
    prob_calc       = prob_calc       if misc.exists(prob_calc       ) else [misc.ProbabilityType.cumulative_prob,misc.ProbabilityType.cumulative_step,misc.ProbabilityType.independent]
    start_from_zero = start_from_zero if misc.exists(start_from_zero ) else [False]
    n_stages        = n_stages        if misc.exists(n_stages        ) else []
    stop_at_food    = stop_at_food    if misc.exists(stop_at_food    ) else [True]

    n_trial_max     = numpy.unique([ plib.trial_to_number(tr.trial) for tr in input_tracks ]).size #n_trials_to_use if n_trials_to_use else max([ int(plib.trial_to_number(tr.trial)) for tr in input_tracks ])
    n_stages_to_use = n_stages
    if force_calc_separate_trials or (len(n_stages) == 0):
        n_stages_to_use = n_stages + [n_trial_max]


    # creating list of configurations
    config = tstep.get_step_prob_input_param_config_list(mouse_part         = mouse_part        ,
                                                         n_stages           = n_stages_to_use   ,
                                                         L_lattice          = L                 ,
                                                         prob_calc          = prob_calc         ,
                                                         start_from_zero    = start_from_zero   ,
                                                         use_extra_trials   = use_extra_trials  ,
                                                         stop_at_food       = stop_at_food      ,
                                                         align_method       = align_method      ,
                                                         use_latest_target  = use_latest_target ,
                                                         use_reverse_target = use_reverse_target)

    config_filtered = config
    print(' ')
    print(' ##########')
    print(' ##########')
    print(' ##########')
    print(' ')
    print(' *** %d configurations were generated...'%len(config_filtered))
    print(' *** this experiment set has %d trials...'%n_trial_max)
    print(' ')
    print(' ##########')
    print(' ##########')
    print(' ##########')
    print(' ')

    print(' ')
    print(' **********    ')
    print(' **********    Running main map calculation')
    print(' **********    ')
    print(' ')


    io.create_output_dir(os.path.join('.',out_dir))

    input_tracks_filtered = omit_mice_if_needed(copy.deepcopy(input_tracks))
    for k,c in enumerate(config_filtered):
        per_completed = 100.0*float(k)/float(len(config_filtered))
        print('* config {0:d}/{1:d} ({2:.2f}%) -- simulating for: '.format(k+1,len(config_filtered),per_completed), end='')
        print(c)
        param_struct   = tstep.get_calc_step_probability_param_struct(**c)
        step_prob_data = tstep.calc_step_probability(param_struct=param_struct,tracks=input_tracks_filtered,return_as_file_struct=True)
        io.save_step_probability_file_struct(out_dir,step_prob_data,ntrials=n_trial_max)


    print(' ')
    print(' **********    ')
    print(' **********    Running jackknife map calculation')
    print(' **********    ')
    print(' ')
    input_tracks_jk = misc.jackknife_track_sample(copy.deepcopy(input_tracks))
    n_sim_total     = float(len(config_filtered) * len(input_tracks_jk))
    sim_counter     = -1
    for n,input_track_jk_sample in enumerate(input_tracks_jk):
        for k,c in enumerate(config_filtered):
            sim_counter  += 1
            per_completed = 100.0*float(sim_counter)/n_sim_total
            print('* config {0:d}/{1:d} ({2:.2f}%) -- simulating for: '.format(k+1,len(config_filtered),per_completed), end='')
            print(c)
            param_struct   = tstep.get_calc_step_probability_param_struct(**c)
            step_prob_data = tstep.calc_step_probability(param_struct=param_struct,tracks=omit_mice_if_needed(input_track_jk_sample),return_as_file_struct=True)
            io.save_step_probability_file_struct(out_dir,step_prob_data,ntrials=n_trial_max,filename_suffix='jackknife'+str(n+1))

    io.fix_step_probability_output_dir_structure(out_dir,n_trial_max)

if __name__ == '__main__':
    main()