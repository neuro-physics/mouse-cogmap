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
# this script plots the processed trajectories

import os
import sys
import copy
import numpy
import argparse
import warnings
import functools
import modules.io as io
import modules.plot_func as pltt
import modules.traj_analysis as tran
import modules.helper_func_class as misc
import modules.traj_to_step_matrix as tstep
import modules.process_mouse_trials_lib as plib
import matplotlib.pyplot as plt

def main():
    # debug
    #sys.argv += [ '-showpic', '-align', './relative_target/mouse_11/mpos_06Sept2019_trial_1_startloc_NE_day_6.mat' ]
    #sys.argv += [ './relative_target/mouse_9/mpos_06Sept2019_trial_5_startloc_SW_day_8.mat',
    #              './relative_target/mouse_10/mpos_06Sept2019_trial_5_startloc_SE_day_8.mat',
    #              './relative_target/mouse_11/mpos_06Sept2019_trial_5_startloc_NE_day_8.mat',
    #              './relative_target/mouse_12/mpos_06Sept2019_trial_5_startloc_NW_day_8.mat']

    #sys.argv += '-showpic -showorigin -showholes ./experiments/fixed_target/mouse_38/mpos_16Jul2021_trial_1_startloc_SE_day_6.mat'.split(' ')
    #sys.argv += '-showpic -showorigin -showholes ./experiments/relative_target/mouse_11/mpos_06Sept2019_trial_1_startloc_NE_day_6.mat ./experiments/fixed_target/mouse_38/mpos_16Jul2021_trial_1_startloc_SE_day_6.mat'.split(' ')
    
    #sys.argv += '-align -showpic -showorigin -showholes ./debug_preprocess/mouse_38/mpos_16Jul2021_trial_1_startloc_SE_day_6.mat ./debug_preprocess/mouse_11/mpos_06Sept2019_trial_1_startloc_NE_day_6.mat debug_preprocess/mouse_6/mpos_23May2019_trial_2_startloc_SE_day_6.mat debug_preprocess/mouse_34/mpos_22Jun2021_trial_2_startloc_SE_day_6.mat'.split(' ')
    
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_38/mpos_16Jul2021_trial_1_startloc_SE_day_6.mat -color time'.split(' ')
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_38/mpos_16Jul2021_trial_2_startloc_NW_day_6.mat -color time'.split(' ')
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_37/mpos_16Jul2021_trial_2_startloc_NE_day_6.mat -color time'.split(' ')
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_39/mpos_16Jul2021_trial_2_startloc_SW_day_6.mat -color time'.split(' ')
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_40/mpos_16Jul2021_trial_2_startloc_SE_day_6.mat -color time'.split(' ')
    
    # these seem to be displaced
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_53/mpos_15Nov2021_trial_2_startloc_NE_day_6.mat -color time'.split(' ')
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_54/mpos_15Nov2021_trial_2_startloc_NW_day_6.mat -color time'.split(' ')
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_55/mpos_15Nov2021_trial_2_startloc_SW_day_6.mat -color time'.split(' ')
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_56/mpos_15Nov2021_trial_2_startloc_SE_day_6.mat -color time'.split(' ')

    # target 1 for 2-target experiment
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_33/mpos_22Jun2021_trial_2_startloc_SW_day_7.mat -color time'.split(' ')
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_33/mpos_22Jun2021_trial_3_startloc_SW_day_7.mat -color time'.split(' ')
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_34/mpos_22Jun2021_trial_2_startloc_SE_day_6.mat -color time'.split(' ')
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_35/mpos_22Jun2021_trial_2_startloc_NE_day_6.mat -color time'.split(' ')
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_36/mpos_22Jun2021_trial_2_startloc_NW_day_7.mat -color time'.split(' ')

    # target 2 for 2-target experiment
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_33/mpos_22Jun2021_trial_23_startloc_SW_day_14.mat -color time'.split(' ')
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_34/mpos_22Jun2021_trial_23_startloc_SE_day_13.mat -color time'.split(' ')
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_35/mpos_22Jun2021_trial_23_startloc_NE_day_13.mat -color time'.split(' ')
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_36/mpos_22Jun2021_trial_23_startloc_NW_day_14.mat -color time'.split(' ')

    # target 1 for 2-target experiment
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_57/mpos_19Nov2021_trial_2_startloc_SW_day_6.mat -color time'.split(' ')
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_58/mpos_19Nov2021_trial_2_startloc_SE_day_6.mat -color time'.split(' ')
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_59/mpos_19Nov2021_trial_2_startloc_NE_day_6.mat -color time'.split(' ')
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_60/mpos_19Nov2021_trial_2_startloc_NW_day_6.mat -color time'.split(' ')

    # target 2 for 2-target experiment
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_57/mpos_19Nov2021_trial_23_startloc_SW_day_13.mat -color time'.split(' ')
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_58/mpos_19Nov2021_trial_23_startloc_SE_day_13.mat -color time'.split(' ')
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_59/mpos_19Nov2021_trial_23_startloc_NE_day_13.mat -color time'.split(' ')
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_60/mpos_19Nov2021_trial_23_startloc_NW_day_13.mat -color time'.split(' ')
    
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_11/mpos_06Sept2019_trial_1_startloc_NE_day_6.mat -color time'.split(' ')
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_6/mpos_23May2019_trial_2_startloc_SE_day_6.mat -color time'.split(' ')
    #sys.argv += '-showpic -showorigin -showholes ./debug_preprocess/mouse_34/mpos_22Jun2021_trial_2_startloc_SE_day_6.mat -color time'.split(' ')

    #sys.argv += 'experiments/two_target_no_cues/mouse_33/mpos_22Jun2021_trial_Habituation_1_startloc_SW_day_2.mat'.split(' ')

    parser = argparse.ArgumentParser(description='Plots 1 up to 10 mouse tracks... If more than 1 entrance is present, only the first arena will be plotted.')
    parser.add_argument('track'            , nargs='*', metavar='TRACK_MAT_FILE', type=str, default=[''] , help='1 up to 10 track files to be plotted')
    parser.add_argument('-stopfood'        , required=False, action='store_true', default=False, help='if set, stops trajectories at food site')
    parser.add_argument('-stoprel'         , required=False, action='store_true', default=False, help='if set, stops trajectories at the reverse target (REL -- rotationally equivalent location)')
    parser.add_argument('-showpic'         , required=False, action='store_true', default=False, help='if set, shows the picture of the real arena in the background')
    parser.add_argument('-showholes'       , required=False, action='store_true', default=False, help='if set, shows the hole positions of the arena with gray circles')
    parser.add_argument('-showrel'         , required=False, action='store_true', default=False, help='if set, shows the REL (ROTATED EQUIVALENT LOCATION) which is not the target, but mice follow if they are rotated')
    parser.add_argument('-showgrid'        , required=False, action='store_true', default=False, help='if set, shows grid lines of the square lattice')
    parser.add_argument('-showorigin'      , required=False, action='store_true', default=False, help='if set, shows the (0,0) point, the origin of the reference frame')
    parser.add_argument('-showspeed'       , required=False, action='store_true', default=False, help='if set, shows a plot of the mouse velocity versus time')
    parser.add_argument('-showchecks'      , required=False, action='store_true', default=False, help='if set, shows mouse checking behavior')
    parser.add_argument('-trim'            , required=False, action='store_true', default=False, help='if set, trims trajectory after visit to either of the target or alternative target (2-targets experiment; not good for REL)')
    parser.add_argument('-align'           , required=False, action='store_true', default=False, help='if set, aligns the entrance of all experiments with the top of the arena')
    parser.add_argument('-L'               , required=False, nargs=1, metavar='int'        , type=int   , default=[0]      ,help='number of squares in one side of the arena grid (if zero, no grid is shown); grid will the sum of all input files')
    parser.add_argument('-lattalpha'       , required=False, nargs=1, metavar='float'      , type=float , default=[1.0]    ,help='transparency of the lattice')
    parser.add_argument('-lattgridalpha'   , required=False, nargs=1, metavar='float'      , type=float , default=[0.2]    ,help='transparency of the lattice grid (if -showgrid is set)')
    parser.add_argument('-trimhorizon'     , required=False, nargs=1, metavar='float'      , type=float , default=[10.0]   ,help='(cm) distance to target (or alt target) used for trimming the trajectory')
    parser.add_argument('-trimdelay'       , required=False, nargs=1, metavar='float'      , type=float , default=[3.0]    ,help='(sec) delay after horizon to target is reached (or alt target) used for trimming the trajectory')
    parser.add_argument('-checkshorizon'   , required=False, nargs=1, metavar='float'      , type=float , default=[3.0]    ,help='(cm) horizon around a hole where mouse nose needs to be to consider a check')
    parser.add_argument('-checksthreshold' , required=False, nargs=1, metavar='float'      , type=float , default=[0.2]    ,help='percent of velocity amplitude if checksmethod==ampv (also this is the behavior if checksmethod==minv); percent of mean if checksmethod==meanv; velocity value if checksmethod==abs;')
    parser.add_argument('-checksvdrop'     , required=False, nargs=1, metavar='float'      , type=float , default=[5.0]    ,help='(cm/s) min velocity drop to be considered for a minimum in velocity')
    parser.add_argument('-checksmethod'    , required=False, nargs=1, metavar='METHOD'     , type=str   , default=['minv'] ,choices=['minv','ampv','meanv','abs'], help='method used to define a hole checking: minv (finds minima in velocity vs. time with given prominence); meanv (slowing down thresholding with percent of mean velocity); ampv (slowing down thresholding with percent of velocity amplitude); abs (slowing down with absolute velocity threshold)')
    parser.add_argument('-color'           , required=False, nargs=1, metavar='COLOR_FEAT' , type=str   , default=['none'] ,choices=['none','velocity','time']   , help='color the trajectory with the provided feature; velocity values (red=high speed,blue=low speed), or time values (purple=beginning; yellow=ending)')

    args = parser.parse_args()

    if not (args.showpic or args.showholes):
        args.showholes = True

    #debug
    #args.track = [ './relative_target/mouse_9/mpos_06Sept2019_trial_5_startloc_SW_day_8.mat',
    #              './relative_target/mouse_10/mpos_06Sept2019_trial_5_startloc_SE_day_8.mat',
    #              './relative_target/mouse_11/mpos_06Sept2019_trial_5_startloc_NE_day_8.mat',
    #              './relative_target/mouse_12/mpos_06Sept2019_trial_5_startloc_NW_day_8.mat']
    #args.align = True
    #args.showpic = True
    #args.L = [11]

    if (len(args.track) == 1) and (len(args.track[0]) == 0):
        inp_dir = os.path.dirname(os.path.realpath(__file__))
        args.track = io.get_files_GUI('Select track files...',inp_dir,wildcard='*.mat',multiple=True,max_num_files=10)

    if args.track is None:
        raise ValueError('You must input at least one track file...')


    tracks = [ io.load_trial_file(p,remove_after_food=False) for p in args.track ]

    # debug
    #for fn,tr in zip(args.track,tracks):
    #    print(fn + '  :::  ' + tr.start_location + '  :::  ' + tr.file_name + '     ->     ' + tr.arena_picture)
    #exit()

    #arena_pic_c = plib.get_cropped_arena_picture(tracks[0],arena_offset_pix=50,bgcolor_rgba=(1,0,0,1))
    #plt.imshow(arena_pic_c, extent=[tracks[0].arena_pic_left, tracks[0].arena_pic_right, tracks[0].arena_pic_bottom, tracks[0].arena_pic_top]) 
    #plt.show()

    use_color = False
    line_color_feat = args.color[0]
    if line_color_feat == 'velocity':
        use_color = True
        color_map = plt.get_cmap('jet')
    elif line_color_feat == 'time':
        use_color = True
        color_map = plt.get_cmap('plasma')

    # shifts all the tracks to match the first one given, since we will use the arena pic of the first track given
    if len(tracks) > 1:
        c_ref = tracks[0].r_arena_center
        for k in range(1,len(tracks)):
            tracks[k] = plib.shift_trial_file(tracks[k],c_ref-tracks[k].r_arena_center)

    rotation_matrix = None
    if args.align:
        align_vector    = numpy.array( (0,1) )
        tracks_R        = plib.rotate_trial_file(tracks,align_vector)
        rotation_matrix = tracks_R[0].R
        tracks          = [ tr.track for tr in tracks_R ]

    if args.stopfood:
        tracks = [ tran.remove_path_after_food(tr,r_target=tr.r_target,return_t_to_food=False,force_main_target=True,hole_horizon=args.trimhorizon[0],time_delay_after_food=args.trimdelay[0]) for tr in tracks ]
        if args.trim or args.stoprel:
            warnings.warn("'trim' and 'stoprel' are ignored")
    elif args.trim:
        tracks = [ tran.remove_path_after_food(tr,force_main_target=False,hole_horizon=args.trimhorizon[0],time_delay_after_food=args.trimdelay[0],copy_tracks=False) for tr in tracks ]
        if args.stoprel:
            warnings.warn("'stoprel' ignored")
    elif args.stoprel:
        tracks = [ tran.remove_path_after_food(tr,r_target=tr.r_target_reverse,return_t_to_food=False,force_main_target=False,hole_horizon=args.trimhorizon[0],time_delay_after_food=args.trimdelay[0]) for tr in tracks ]

    if args.showchecks:
        use_velocity_minima  = args.checksmethod[0] == 'minv'
        args.checksmethod[0] = 'ampv' if use_velocity_minima else args.checksmethod[0]
        k_slow,t_slow,r_slow,v_th = misc.unpack_list_of_tuples([ tran.find_slowing_down_close_to_hole(tr,args.checkshorizon[0],threshold_method=args.checksmethod[0],gamma=args.checksthreshold[0],
                                                                                                 return_pos_from='hole',ignore_entrance_positions=False,
                                                                                                 use_velocity_minima=use_velocity_minima,velocity_min_prominence=args.checksvdrop[0]) for tr in tracks ])

    arena_pic = False
    if args.showpic:
        # the picture below is already rotated if R is defined
        arena_pic = plib.rotate_arena_picture(plib.get_cropped_arena_picture(tracks[0],bgcolor_rgba=(1,1,1,1)),rotation_matrix,tracks[0],(1,1,1,1))

    G = numpy.array([])
    if args.L[0] > 0:
        L = args.L[0]
        G = functools.reduce(lambda A,B:A+B,[ tstep.count_number_of_steps_in_lattice(tr.time,tr.r_nose,L,r_center=tr.r_arena_center)[1] for tr in tracks ]) # sum all the grid matrices


    show_alt_target = numpy.any([ not numpy.any(numpy.isnan(tr.r_target_alt)) for tr in tracks ])

    ax = pltt.plot_arena_sketch(tracks[0],showAllEntrances=not args.align,arenaPicture=arena_pic,showHoles=args.showholes)
    if args.L[0] > 0:
        pltt.plot_arena_grid(ax,G,track=tracks[0],line_color=(0.8,0.8,0.8,args.lattgridalpha[0]),show_grid_lines=args.showgrid,grid_alpha=args.lattalpha[0])
    if use_color:
        pltt.plot_mouse_trajectory(ax,tracks,'nose',color=color_map,line_gradient_variable=line_color_feat,linewidth=2,show_reverse_target=args.showrel,show_alt_target=show_alt_target)
    else:
        pltt.plot_mouse_trajectory(ax,tracks,mouse_part='nose',show_reverse_target=args.showrel,show_alt_target=show_alt_target)
    if args.showchecks:
        for k,(ind,r,tr) in enumerate(zip(k_slow,r_slow,tracks)):
            t_seq = tr.time[ind]/tr.time[-1]
            checks_color = plt.get_cmap('plasma')(t_seq) if use_color else 'm'
            pltt.plot_trajectory_points(r,ax=ax,use_scatter=True,s=1e2*t_seq,marker='o',c=checks_color,zorder=10000+k,alpha=0.8)
    if args.showorigin:
        ax.plot(0,0,'ok',markersize=6,zorder=1003,label='origin')
    ax.legend(loc='upper left',bbox_to_anchor=(-0.05,1))

    if args.showspeed:
        _,ax = plt.subplots(nrows=2,ncols=1,sharex=True,sharey=False,figsize=(8,8))
        for tr in tracks:
            a = tran.calc_acceleration(tr)
            ax[0].plot(tr.time,tr.velocity,'-b')
            ax[1].plot(tr.time,a          ,'-r')
            ax[0].set_xlabel('Time (sec)')
            ax[1].set_xlabel('Time (sec)')
            ax[0].set_ylabel('Velocity (cm/s)')
            ax[1].set_ylabel('Acceleration (cm/s$^2$)')
        if args.showchecks:
            for k,(ind,r,tr) in enumerate(zip(k_slow,r_slow,tracks)):
                a = tran.calc_acceleration(tr)
                t_seq = tr.time[ind]/tr.time[-1]
                checks_color = plt.get_cmap('plasma')(t_seq) if use_color else 'm'
                ax[0].scatter(tr.time[ind],tr.velocity[ind],s=1e2*t_seq,marker='o',c=checks_color,zorder=10000+k,alpha=0.8)
                ax[1].scatter(tr.time[ind],a[ind]          ,s=1e2*t_seq,marker='o',c=checks_color,zorder=10000+k,alpha=0.8)

    plt.show()

if __name__ == '__main__':
    main()