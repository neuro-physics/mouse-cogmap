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
# this script is only here for reference on how the excel files were processed

import os
import sys
import numpy
import modules.io as io
import modules.helper_func_class as misc
import modules.process_mouse_trials_lib as plib

def main():
    clear_output_directory = True
    ntrials_to_process     = None

    """
    # experiments where mice are trained in "static entrance protocol" until first probe at least
    # 2019-05-23 # preliminary
    # 2021-06-22 # two targets
    # 2021-11-19 # two targets
    # 2022-08-12 # two targets rotated probe
    # 2022-09-20 # two targets with rotated probe (female mice)
    # 2022-10-11 # two targets rotated probe mixed sex
    # 2022-11-04 # relative target (aka static entrance) - after trial 21 (at the probe), two mice (out of 4) get 90 degrees rotation

    # relative target (aka static entrance)
    # 2019-10-07
    # 2019-09-06

    # fixed target (aka random entrance)
    # 2021-07-16
    # 2021-11-15

    # two targets
    # 2021-11-19
    # 2021-06-22

    # preliminary experiments
    # 2019-05-23

    # two targets with rotated probe
    # 2022-08-12

    # two targets with rotated probe and mixed sex mice
    # 2022-10-11

    # two targets with rotated probe (female mice)
    # 2022-09-20 :: two_targets_rot_fem

    # relative target (aka static entrance) - after trial 21, two mice get 90 degrees rotation
    # 2022-11-04
    """

    preprocess_experiment('relative_target'                , clear_output_directory, ntrials_to_process)
    preprocess_experiment('fixed_target'                   , clear_output_directory, ntrials_to_process)
    preprocess_experiment('two_targets'                    , clear_output_directory, ntrials_to_process)
    preprocess_experiment('preliminary'                    , clear_output_directory, ntrials_to_process)
    preprocess_experiment('two_targets_rot'                , clear_output_directory, ntrials_to_process)
    preprocess_experiment('two_targets_rot_mixsex'         , clear_output_directory, ntrials_to_process)
    preprocess_experiment('two_targets_rot_fem'            , clear_output_directory, ntrials_to_process)
    preprocess_experiment('relative_target_90deg'          , clear_output_directory, ntrials_to_process)
#end main

def preprocess_experiment(experiment,clear_output_directory,ntrials_to_process):
    experiment = experiment.lower()
    valid_experiments = ['relative_target','fixed_target','two_targets','preliminary','two_targets_rot','two_targets_rot_mixsex','two_targets_rot_fem','relative_target_90deg']
    assert experiment in valid_experiments, "experiment must one of %s"%(  str(valid_experiments)[1:-1].replace("'",'')  )

    this_directory = sys.path[0]

    process_param = []
    if experiment == 'relative_target':
        clear_output_directory = [clear_output_directory,False]
        process_param = [
            # second set of experiments
            dict( trial_dir              = os.path.join(this_directory,'../EthovisionPathAnalysis/Raw Trial Data/2019-10-07_Raw Trial Data'),
                  out_dir                = os.path.join(this_directory,'experiments/relative_target' ),
                  trials_to_process      = 'all', # trials to process; available values in plib.ethovision_to_track_matfile
                  replacement_dict       = {}, # no trial label replacements
                  correct_distortion     = False,
                  mouse_gender           = {} ,
                  correct_arena_center   = False ),
            # third set of experiments
            dict( trial_dir              = os.path.join(this_directory,'../EthovisionPathAnalysis/Raw Trial Data/2019-09-06_Raw Trial Data'),
                  out_dir                = os.path.join(this_directory,'experiments/relative_target' ),
                  trials_to_process      = 'all', # trials to process; available values in plib.ethovision_to_track_matfile
                  replacement_dict       = {}, # no trial label replacements
                  correct_distortion     = False ,
                  mouse_gender           = {} ,
                  correct_arena_center   = False )
        ]
    elif experiment == 'fixed_target':
        clear_output_directory = [clear_output_directory,False]
        process_param = [
            # third set of experiments
            dict( trial_dir              = os.path.join(this_directory,'../EthovisionPathAnalysis/Raw Trial Data/2021-07-16_Raw Trial Data'),
                  out_dir                = os.path.join(this_directory,'experiments/fixed_target' ),
                  trials_to_process      = 'all', # trials to process; available values in plib.ethovision_to_track_matfile
                  replacement_dict       = {}, # no trial label replacements
                  correct_distortion     = False ,
                  mouse_gender           = {} ,
                  correct_arena_center   = False ),
            # third set of experiments
            dict( trial_dir              = os.path.join(this_directory,'../EthovisionPathAnalysis/Raw Trial Data/2021-11-15_Raw Trial Data'),
                  out_dir                = os.path.join(this_directory,'experiments/fixed_target' ),
                  trials_to_process      = 'all', # trials to process; available values in plib.ethovision_to_track_matfile
                  replacement_dict       = {}, # no trial label replacements
                  correct_distortion     = True , # we want to correct the distortion in this experiment to match the 16-July-2021 one
                  mouse_gender           = {} ,
                  correct_arena_center   = True )
        ]
    elif experiment == 'two_targets':
        clear_output_directory = [clear_output_directory,False]
        process_param = [
            # fourth set of experiments
            dict( trial_dir              = os.path.join(this_directory,'../EthovisionPathAnalysis/Raw Trial Data/2021-11-19_Raw Trial Data'),
                  out_dir                = os.path.join(this_directory,'experiments/two_target_no_cues'),
                  trials_to_process      = 'all', # trials to process; available values in plib.ethovision_to_track_matfile
                  replacement_dict       = {'Reverse':'Probe'}, # we are renaming the 'Reverse' trials to 'Probe' ###  this dictionary is used to replace the key trial label with the value label; in this case,
                  correct_distortion     = False, # False for correct distortion
                  mouse_gender           = {} ,
                  correct_arena_center   = False ), 
            # fourth set of experiments
            dict( trial_dir              = os.path.join(this_directory,'../EthovisionPathAnalysis/Raw Trial Data/2021-06-22_Raw Trial Data'),
                  out_dir                = os.path.join(this_directory,'experiments/two_target_no_cues'),
                  trials_to_process      = 'all', # trials to process; available values in plib.ethovision_to_track_matfile
                  replacement_dict       = {}, # no trial label replacements
                  correct_distortion     = False ,
                  mouse_gender           = {} ,
                  correct_arena_center   = False )
        ]
    elif experiment == 'two_targets_rot':
        clear_output_directory = [clear_output_directory]
        process_param = [
            # fifth set of experiments
            dict( trial_dir              = os.path.join(this_directory,'../EthovisionPathAnalysis/Raw Trial Data/2022-08-12_Raw Trial Data'),
                  out_dir                = os.path.join(this_directory,'experiments/two_targets_rot'),
                  trials_to_process      = 'all', # trials to process; available values in plib.ethovision_to_track_matfile
                  replacement_dict       = {}, # no trial label replacements
                  correct_distortion     = True ,
                  mouse_gender           = {} ,
                  correct_arena_center   = True )
        ]
    elif experiment == 'two_targets_rot_mixsex':
        clear_output_directory = [clear_output_directory]
        process_param = [
            # fifth set of experiments
            dict( trial_dir              = os.path.join(this_directory,'../EthovisionPathAnalysis/Raw Trial Data/2022-10-11_Raw Trial Data'),
                  out_dir                = os.path.join(this_directory,'experiments/two_targets_rot_mixsex'),
                  trials_to_process      = 'all', # trials to process; available values in plib.ethovision_to_track_matfile
                  replacement_dict       = {}, # no trial label replacements
                  correct_distortion     = True ,
                  mouse_gender           = { 1:'F', 6:'F', 8:'F' },
                  correct_arena_center   = True ) # dict that links mouse_number to mouse_gender flag ('F' for female, 'M' for male; default: 'M'); mouse_number must be int or convertible to int
        ]
    elif experiment == 'preliminary':
        clear_output_directory = [clear_output_directory]
        process_param = [
            # first set of experiments
            dict( trial_dir              = os.path.join(this_directory,'../EthovisionPathAnalysis/Raw Trial Data/2019-05-23_Raw Trial Data'),
                  out_dir                = os.path.join(this_directory,'experiments/preliminary' ),
                  trials_to_process      = 'all', # trials to process; available values in plib.ethovision_to_track_matfile
                  replacement_dict       = {}, # no trial label replacements
                  correct_distortion     = False ,
                  mouse_gender           = {} ,
                  correct_arena_center   = False )
        ]
    elif experiment == 'two_targets_rot_fem':
        clear_output_directory = [clear_output_directory]
        process_param = [
        # another set (not sure if this belongs here... waiting Kelly's answer)
            dict( trial_dir              = os.path.join(this_directory,'../EthovisionPathAnalysis/Raw Trial Data/2022-09-20_Raw Trial Data'),
                  out_dir                = os.path.join(this_directory,'experiments/two_targets_rot_fem'),
                  trials_to_process      = 'all', # trials to process; available values in plib.ethovision_to_track_matfile
                  replacement_dict       = {}, # no trial label replacements
                  correct_distortion     = False,
                  mouse_gender           = {73:'F', 74:'F', 75:'F', 76:'F'} ,
                  correct_arena_center   = False)
        ]
    elif experiment == 'relative_target_90deg':
        clear_output_directory = [clear_output_directory]
        process_param = [
        # another set (not sure if this belongs here... waiting Kelly's answer)
            dict( trial_dir              = os.path.join(this_directory,'../EthovisionPathAnalysis/Raw Trial Data/2022-11-04_Raw Trial Data'),
                  out_dir                = os.path.join(this_directory,'experiments/relative_target_90deg'),
                  trials_to_process      = 'all', # trials to process; available values in plib.ethovision_to_track_matfile
                  replacement_dict       = {}, # no trial label replacements
                  correct_distortion     = False,
                  mouse_gender           = {} ,
                  correct_arena_center   = False)
        ]
    else:
        raise ValueError('Unknown experiment %s'%experiment)

    for parval,cleardir in zip(process_param,clear_output_directory):
        process_trajectory_files(True,cleardir,ntrials_to_process=ntrials_to_process,**parval)
    
    io.write_txt_header_from_dict(os.path.join(process_param[0]['out_dir'],'experiment_process_params.txt'),process_param,replace=True,hchar='#',verbose=True)

#end preprocess_experiment

def process_trajectory_files(do_processing,clear_output_directory,ntrials_to_process=None,trial_dir=None,out_dir=None,trials_to_process=None,replacement_dict=None,correct_distortion=None,mouse_gender=None,correct_arena_center=False):
    ########################
    ################
    ########
    # input/output configuration

    # number of rows to skip in the beginning of each trial excel file
    #n_rows_skip = 37 # defined automatically for each ioDir group defined below

    if not misc.exists(ntrials_to_process):
        ntrials_to_process = -1

    if clear_output_directory:
        io.clear_directory(out_dir,verbose=True)
    #    out_dir_list = list(dict.fromkeys([ d for p,_,d in ioDir if p ]))
    #    io.clear_directory(out_dir_list,verbose=True)

    # for debug only
    #ioDir = [
    ## first set of experiments
    #    ( True,
    #      'D:/Dropbox/p/uottawa/data/animal_trajectories/EthovisionPathAnalysis/Raw Trial Data/2019-10-07_Raw Trial Data',
    #      'D:/Dropbox/p/uottawa/data/animal_trajectories/mouse_track/debug_output_mouse_trajectories' )
    #      ]

    ########################
    ################
    ########
    # running

    #for do_processing,trial_dir,out_dir,trials_to_process,replacement_dict,correct_distortion in ioDir:
    #    if not do_processing:
    #        continue
    if do_processing:
        print('--------------------------')
        print('--------------------------')
        print('--------------------------')
        print('--------------------------')
        print('STARTING TO PROCESS ... %s'%io.get_filename(trial_dir))

        io.create_output_dir(out_dir)

        trial_files = plib.get_trial_files(trial_dir,file_ptrn='*-Trial*.xlsx')

        n_rows_skip = plib.get_n_header_rows(trial_files[0][1])

        n_processed_files = 0
        mouse_dir = []
        for _,fname in trial_files:
            n_processed_files += 1
            if (ntrials_to_process > 0) and (n_processed_files == ntrials_to_process):
                print('   reached the limit number of files -> %d ::: Stopping'%ntrials_to_process)
                break
            percent_process = 100.0*float(n_processed_files)/float(len(trial_files))
            print('%.2f%% -- Processing %s ...'%(percent_process,io.get_filename(fname)))
            track = plib.ethovision_to_track_matfile(fname,num_of_header_rows_in_excel=n_rows_skip-1,trials_to_process=trials_to_process,correct_distortion=correct_distortion,mouse_gender=mouse_gender,correct_arena_center=correct_arena_center)
            if misc.exists(track):
                fn    = io.save_trial_file(out_dir,track)
                mouse_dir.append(fn)
            else:
                print('        ... ::: skipping')

        if len(replacement_dict) > 0:
            mouse_dir = numpy.unique([ os.path.split(md)[0] for md in mouse_dir ])
            for md in mouse_dir:
                io.replace_tracks_trial_label(str(md),replacement_dict)

#end process_trajectory_files
    
if __name__ == '__main__':
    main()