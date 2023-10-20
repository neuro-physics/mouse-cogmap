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
# this scripts tests the parameters extracted from the arena

import os
import copy
import numpy
import modules.io as io
import modules.plot_func as pltt
import modules.traj_analysis as tran
import modules.edge_detector as edged
import modules.helper_func_class as misc
import modules.traj_to_step_matrix as tstep
import modules.process_mouse_trials_lib as plib
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import PIL.Image

def run_tests(
    TEST_ARENA_FEAT                           = False,
    TEST_ARENA_CROP                           = False,
    TEST_ROTATION                             = False,
    TEST_ARENA_IMG_ROTATION                   = False,
    TEST_STEP_MATRIX                          = False,
    TEST_CIRCULAR_GRID                        = False,
    TEST_PROBABILITY_STEP                     = False,
    TEST_MOUSE_VECTOR                         = False,
    TEST_VELOCITY_THRESHOLD                   = False,
    TEST_ARENA_COORD                          = False,
    TEST_VECTOR_ANGLES                        = False,
    TEST_FIND_TRAJECTORY                      = False,
    TEST_COORD_HISTOGRAM                      = False,
    TEST_STEPPROB_PATH                        = False,
    TEST_ARENA_PICTURES_COMPARE               = False,
    TEST_PREPROCESS_2TARGET                   = False,
    TEST_PLOT_ALL_ARENA_CENTERS               = False,
    TEST_ARENA_SHIFT_PIC                      = False,
    TEST_ARENA_ALIGNMENT                      = False,
    TEST_FIND_CLUSTERS_ARRAY                  = False,
    TEST_FIND_ARENA_HOLES                     = False,
    TEST_ARENA_IMG_EXTENT                     = False,
    TEST_HOLE_DETECTION_EXTENT_POSITION       = False,
    TEST_FIND_SELF_INTERSECTIONS_MOUSE        = False,
    TEST_FIND_SELF_INTERSECTIONS              = False,
    TEST_REMOVE_SLOW_PARTS                    = False,
    TEST_2TARGETS_TRACK_TRIM                  = False,
    TEST_AVG_OVER_DISPLACEMENT                = False,
    TEST_CUMULATIVE_N_CHECKED_HOLES           = False,
    TEST_PLOT_CHECKED_HOLE_DISPERSION         = False,
    TEST_RANDOM_ENTRANCE_ALIGNMENT            = False,
    TEST_GENERATE_RANDOM_ENTRANCE_ALIGN_PLOTS = False,
    TEST_DISTORT_TRANSFORM_RANDOM_ENTRANCE    = False,
    TEST_ALIGN_TARGET_RANDOM_ENTRANCE         = False,
    TEST_HOLE_CHECK_DETECTION_HIGH_SPEED      = False,
    TEST_PROBE2_LATTICE_WALK                  = False,
    TEST_FIND_HOLE_CHECK_PAPER                = False):


    if TEST_ARENA_FEAT or TEST_ARENA_CROP or TEST_ROTATION or TEST_ARENA_IMG_ROTATION:
        arena_file_dir = './arena_picture'
        arena_pic_files = { k: os.path.join(arena_file_dir,v) for k,v in plib.get_arena_all_picture_filename().items() }

        track_files = ['./experiments/fixed_target/mouse_5/mpos_23May2019_trial_4_startloc_SW_day_7.mat',
                    './experiments/fixed_target/mouse_6/mpos_23May2019_trial_6_startloc_SE_day_8.mat',
                    './experiments/fixed_target/mouse_7/mpos_23May2019_trial_6_startloc_NE_day_8.mat',
                    './experiments/fixed_target/mouse_8/mpos_23May2019_trial_7_startloc_NW_day_9.mat']
        tracks = [ io.load_trial_file(p) for p in track_files ]

        c = plib.get_arena_center()
        # c[1] = 1.2166667 # proable correction? no, it gets very bad
        r = 60.0 # arena radius
        r_holes = plib.get_arena_hole_coord()
        r_ent = plib.get_arena_entrance_coord()
        ent_txt_valign = { k:('baseline' if e[1] > 0 else 'top') for k,e in r_ent.items() }
        ent_txt_halign = { k:('left' if e[0] > 0 else 'right') for k,e in r_ent.items() }

        fig_w,fig_h = 8,6
        arena_wh = (640,480)
        ax_w = 1.2
        ax_hw_ratio = arena_wh[1] / arena_wh[0] # h and w of the arena_picture
        ax_h = ax_w * ax_hw_ratio

    def plot_arena_with_feat(lab,showpic=True):
        _,ax = plt.subplots(figsize=(fig_w,fig_h))
        ax.set_position([ (1.0-ax_w)/2.0, (1.0-ax_h)/2.0, ax_w, ax_h ])
        if showpic:
            ax.imshow(mpimg.imread(arena_pic_files[lab]), extent=(-97,97,-73,73) )
        else:
            ax.set_aspect('equal')
            ax.set_xlim([-97,97])
            ax.set_ylim([-73,73])
            ax.set_autoscale_on(False)
        ax.plot(r_holes[:,0],r_holes[:,1],'om',fillstyle='none')
        ax.plot(c[0],c[1],'+b')
        ax.plot(r_ent[lab][0],r_ent[lab][1],'xb',markersize=20)
        ax.annotate(lab,r_ent[lab],verticalalignment=ent_txt_valign[lab], horizontalalignment=ent_txt_halign[lab], color='w', fontsize=20)
        arena_circ = plt.Circle(c, r, color='r',fill=False)
        ax.add_patch(arena_circ)
        ax.set_title(lab + ' - ' + arena_pic_files[lab])

    if TEST_ARENA_FEAT:
        plot_arena_with_feat('SW')
        plot_arena_with_feat('SE')
        plot_arena_with_feat('NE')
        plot_arena_with_feat('NW')
        plt.show()


    if TEST_ARENA_CROP:
        for k in range(len(tracks)):
            _,ax = plt.subplots(figsize=(fig_w,fig_h))
            ax.set_position([ (1.0-ax_w)/2.0, (1.0-ax_h)/2.0, ax_w, ax_h ])
            arena_pic_c = plib.get_cropped_arena_picture(tracks[k],arena_offset_pix=50,bgcolor_rgba=(1,0,0,1))
            ax.imshow(arena_pic_c, extent=[tracks[k].arena_pic_left, tracks[k].arena_pic_right, tracks[k].arena_pic_bottom, tracks[k].arena_pic_top]) 
            ax.set_title(tracks[k].start_location + ' - ' + track_files[k])
        plt.show()


    if TEST_ROTATION:
        # defining rotation wrt picture (0,0)
        R0 = misc.RotateTransf( tracks[0].r_start-tracks[0].r_arena_center, tracks[0].arena_diameter*numpy.array((0,1)) ) # we want the axis of rotation to be in track.r_arena_center
        R0r_start = R0(tracks[0].r_start)

        # defining rotation wrt arena center
        R = misc.RotateTransf( tracks[0].r_start-tracks[0].r_arena_center, tracks[0].arena_diameter*numpy.array((0,1)), tracks[0].r_arena_center ) # we want the axis of rotation to be in track.r_arena_center
        R_30 = misc.RotateTransf( [], [], tracks[0].r_arena_center, angle=30*numpy.pi/180 )
        R_60 = misc.RotateTransf( [], [], tracks[0].r_arena_center, angle=60*numpy.pi/180 )
        R_90 = misc.RotateTransf( [], [], tracks[0].r_arena_center, angle=90*numpy.pi/180 )

        Rr_start = R(tracks[0].r_start)
        R30r_holes = R_30(r_holes)
        R60r_holes = R_60(r_holes)
        R90r_holes = R_90(r_holes)
        
        # defining the vectors with respect to arena center
        r_start_vec = tracks[0].r_start - tracks[0].r_arena_center
        r_start_vec_R = Rr_start - tracks[0].r_arena_center
        print('|r| = {:g}'.format(numpy.linalg.norm(r_start_vec)))
        print('|Rr| = {:g}'.format(numpy.linalg.norm(r_start_vec_R)))
        plot_arena_with_feat(tracks[0].start_location,False)
        #plt.arrow(0,0,r_start_vec[0],r_start_vec[1],length_includes_head=True,head_width=2)
        #plt.arrow(0,0,r_start_vec_R[0],r_start_vec_R[1],length_includes_head=True,head_width=2)
        plt.arrow(tracks[0].r_arena_center[0],tracks[0].r_arena_center[1],r_start_vec[0],r_start_vec[1],length_includes_head=True,head_width=2)
        plt.arrow(tracks[0].r_arena_center[0],tracks[0].r_arena_center[1],r_start_vec_R[0],r_start_vec_R[1],length_includes_head=True,head_width=2)
        plt.plot(Rr_start[0],Rr_start[1],'xy',markersize=20)
        plt.plot(R0r_start[0],R0r_start[1],'xc',markersize=20)
        plt.plot(R30r_holes[:,0],R30r_holes[:,1],'^k',fillstyle='none')
        plt.plot(R60r_holes[:,0],R60r_holes[:,1],'sm',fillstyle='none')
        plt.plot(R90r_holes[:,0],R90r_holes[:,1],'vk',fillstyle='none')
        plt.show()



    if TEST_ARENA_IMG_ROTATION:
        img = plib.get_arena_picture(tracks[0])
        R = misc.RotateTransf( tracks[0].r_start-tracks[0].r_arena_center, tracks[0].arena_diameter*numpy.array((0,1)), tracks[0].r_arena_center ) # we want the axis of rotation to be in track.r_arena_center
        img_r = plib.rotate_arena_picture(img,R,tracks[0],(1,0,0,1))
        Rr_holes = R(r_holes)
        _,ax = plt.subplots(figsize=(fig_w,fig_h))
        ax.set_position([ (1.0-ax_w)/2.0, (1.0-ax_h)/2.0, ax_w, ax_h ])
        plt.imshow(img, extent=(-97,97,-73,73) )
        plt.plot(r_holes[:,0],r_holes[:,1],'om',fillstyle='none')
        _,ax = plt.subplots(figsize=(fig_w,fig_h))
        ax.set_position([ (1.0-ax_w)/2.0, (1.0-ax_h)/2.0, ax_w, ax_h ])
        plt.imshow(img_r, extent=(-97,97,-73,73) )
        plt.plot(Rr_holes[:,0],Rr_holes[:,1],'om',fillstyle='none')
        plt.show()


    if TEST_STEP_MATRIX:
        track_files = [ './experiments/relative_target/mouse_9/mpos_06Sept2019_trial_5_startloc_SW_day_8.mat',
                        './experiments/relative_target/mouse_10/mpos_06Sept2019_trial_6_startloc_SE_day_8.mat',
                        './experiments/relative_target/mouse_11/mpos_06Sept2019_trial_5_startloc_NE_day_8.mat',
                        './experiments/relative_target/mouse_12/mpos_06Sept2019_trial_7_startloc_NW_day_9.mat']
        L = 21
        tracks = io.load_trial_file(track_files)
        N,G,_,_ = tstep.count_number_of_steps_in_lattice(tracks[0].time,tracks[0].r_nose,L,r_center=tracks[0].r_arena_center)
        ax = pltt.plot_arena_sketch(tracks[0])
        pltt.plot_arena_grid(ax,G,line_color=(0.8,0.8,0.8),show_grid_lines=True)
        pltt.plot_mouse_trajectory(ax,tracks[0],mouse_part='nose')
        
        N,G,_,_ = tstep.count_number_of_steps_in_lattice(tracks[1].time,tracks[1].r_nose,L,r_center=tracks[1].r_arena_center)
        ax = pltt.plot_arena_sketch(tracks[1])
        pltt.plot_arena_grid(ax,G,line_color=(0.8,0.8,0.8),show_grid_lines=True)
        pltt.plot_mouse_trajectory(ax,tracks[1],mouse_part='nose')
        
        N,G,_,_ = tstep.count_number_of_steps_in_lattice(tracks[2].time,tracks[2].r_nose,L,r_center=tracks[2].r_arena_center)
        ax = pltt.plot_arena_sketch(tracks[2])
        pltt.plot_arena_grid(ax,G,line_color=(0.8,0.8,0.8),show_grid_lines=True)
        pltt.plot_mouse_trajectory(ax,tracks[2],mouse_part='nose')
        
        N,G,_,_ = tstep.count_number_of_steps_in_lattice(tracks[3].time,tracks[3].r_nose,L,r_center=tracks[3].r_arena_center)
        ax = pltt.plot_arena_sketch(tracks[3])
        pltt.plot_arena_grid(ax,G,line_color=(0.8,0.8,0.8),show_grid_lines=True)
        pltt.plot_mouse_trajectory(ax,tracks[3],mouse_part='nose')
        plt.show()


    if TEST_CIRCULAR_GRID:
        track_file = './experiments/relative_target/mouse_9/mpos_06Sept2019_trial_5_startloc_SW_day_8.mat'
        track = plib.rotate_trial_file(io.load_trial_file(track_file),numpy.array((0,1))).track
        
        L_lattice = 11
        r = numpy.delete(track.r_nose,numpy.unique(numpy.nonzero(numpy.isnan(track.r_nose))[0]),axis=0)
        T = tstep.get_arena_to_lattice_transform(L_lattice)
        r_latt = tstep.apply_arena_to_lattice_transform(T,r)
        _,grid,_,_= tstep.get_circular_grid_graph(L_lattice)
        arena_circ = plt.Circle(tstep.apply_arena_to_lattice_transform(T,plib.get_arena_center()), tstep.get_circular_grid_radius(L_lattice), color='k', fill=False)
        #plt.plot(r[:,0],r[:,1],'--b')
        plt.imshow(grid)
        plt.gca().add_patch(arena_circ)
        plt.plot(r_latt[:,0],r_latt[:,1],'-or',fillstyle='none')
        plt.show()

    if TEST_PROBABILITY_STEP:
        inp_dir = 'experiments/relative_target'
        out_dir = 'output_test'
        io.create_output_dir(out_dir)
        # stepmat_nose_L_11_nstages_3_ntrials_16_Pinit_0.0_cstep_continuefood.mat
        c1 = tstep.get_calc_step_probability_param_struct(L_lattice=11, mouse_part='nose', n_stages=3,  prob_calc=misc.ProbabilityType.cumulative_prob, start_from_zero=False, stop_at_food=True, use_extra_trials=True)
        c2 = tstep.get_calc_step_probability_param_struct(L_lattice=31, mouse_part='nose', n_stages=3,  prob_calc=misc.ProbabilityType.cumulative_step, start_from_zero=True,  stop_at_food=True, use_extra_trials=True)
        c3 = tstep.get_calc_step_probability_param_struct(L_lattice=51, mouse_part='nose', n_stages=16, prob_calc=misc.ProbabilityType.independent,     start_from_zero=True,  stop_at_food=True, use_extra_trials=True)
        step_prob_data1 = tstep.calc_step_probability(mouse_dir=inp_dir,param_struct=c1,return_as_file_struct=True)
        step_prob_data2 = tstep.calc_step_probability(mouse_dir=inp_dir,param_struct=c2,return_as_file_struct=True)
        step_prob_data3 = tstep.calc_step_probability(mouse_dir=inp_dir,param_struct=c3,return_as_file_struct=True)
        io.save_step_probability_file_struct(out_dir,step_prob_data1)
        io.save_step_probability_file_struct(out_dir,step_prob_data2)
        io.save_step_probability_file_struct(out_dir,step_prob_data3)

    if TEST_MOUSE_VECTOR:
        track_files = ['./experiments/fixed_target/mouse_5/mpos_23May2019_trial_4_startloc_SW_day_7.mat',
                './experiments/fixed_target/mouse_6/mpos_23May2019_trial_6_startloc_SE_day_8.mat',
                './experiments/fixed_target/mouse_7/mpos_23May2019_trial_6_startloc_NE_day_8.mat',
                './experiments/fixed_target/mouse_8/mpos_23May2019_trial_7_startloc_NW_day_9.mat']
        tracks = io.load_trial_file(track_files)
        mouse_vec = tracks[0].r_nose - tracks[0].r_center
        food_vec = tracks[0].r_target - tracks[0].r_start
        theta = misc.angle_uv(mouse_vec,food_vec,axis=1)
        plt.figure(1)
        plt.plot(tracks[0].time,theta)
        plt.figure(2)
        plt.plot(tracks[0].time,tracks[0].velocity)
        plt.show()


    if TEST_VELOCITY_THRESHOLD:
        mouse = io.load_trial_file('./experiments/fixed_target/mouse_5/mpos_23May2019_trial_4_startloc_SW_day_7.mat')
        t_cross1,IEI1,v_th1 = tran.calc_velocity_crossings(mouse,threshold_method='ampv',gamma=0.2,only_slowing_down=False)
        t_cross2,IEI2,v_th2 = tran.calc_velocity_crossings(mouse,threshold_method='ampv',gamma=0.15,only_slowing_down=True)
        t_cross3,IEI3,v_th3 = tran.calc_velocity_crossings(mouse,threshold_method='meanv',gamma=0.2,only_slowing_down=False)
        t_cross4,IEI4,v_th4 = tran.calc_velocity_crossings(mouse,threshold_method='meanv',gamma=0.25,only_slowing_down=True)
        plt.figure(1)
        ax = plt.gca()
        colors = plt.get_cmap('tab10')(numpy.linspace(0,1,4))
        ax.plot(mouse.time, mouse.velocity,'-k',linewidth=1)
        pltt.plot_horizontal_lines(v_th1,ax=ax,color=colors[0],linestyle='--',zorder=1000)
        pltt.plot_horizontal_lines(v_th2,ax=ax,color=colors[1],linestyle='--',zorder=1001)
        pltt.plot_horizontal_lines(v_th3,ax=ax,color=colors[2],linestyle='--',zorder=1002)
        pltt.plot_horizontal_lines(v_th4,ax=ax,color=colors[3],linestyle='--',zorder=1003)
        ax.plot(t_cross1,v_th1*numpy.ones(t_cross1.size),'o',color=colors[0],markersize=4)
        ax.plot(t_cross2,v_th2*numpy.ones(t_cross2.size),'s',color=colors[1],markersize=4)
        ax.plot(t_cross3,v_th3*numpy.ones(t_cross3.size),'^',color=colors[2],markersize=4)
        ax.plot(t_cross4,v_th4*numpy.ones(t_cross4.size),'v',color=colors[3],markersize=4)
        plt.show()


    def plot_point(r,label='',fmt='o',color='k',markersize=6,ax=None,**textArgs):
        if ax is None:
            ax = plt.gca()
        ax.plot(r[0],r[1],fmt,color=color,markersize=markersize,fillstyle='none')
        if len(label)>0:
            ax.text(r[0],r[1],label,**textArgs)
    def plot_arrow(r0,r1,label='',labelpos=None,color='k',ax=None,arrowArgs=None,**textArgs):
        if ax is None:
            ax = plt.gca()
        if arrowArgs is None:
            arrowArgs = {}
        arrowArgs_new = dict(length_includes_head=True,head_width=2,color=color)
        arrowArgs_new.update(arrowArgs)
        ax.arrow(r0[0],r0[1],r1[0]-r0[0],r1[1]-r0[1],**arrowArgs_new)
        if len(label)>0:
            labelpos = labelpos if labelpos else 'center'
            if labelpos == 'end':
                lp = r1
            elif labelpos == 'start':
                lp = r0
            else:
                lp = r0+(r1 - r0)/2.0 # center
            ax.text(lp[0],lp[1],label,**textArgs)
    def plot_mouse(mou,t_ind,colors,fontsize=9,zero_vec_alpha=0.2,show_labels=False,vec_label='',labelpos='center',vec_fontsize=10,vec_text_args={}):
        plot_point(mou.r_nose[t_ind],'nose' if show_labels else '',fmt='^',color=colors[0],markersize=3,va='bottom',ha='left',fontsize=fontsize)
        plot_arrow(numpy.zeros(2),mou.r_nose[t_ind],'',color=numpy.insert(colors[0][:3],3,zero_vec_alpha),fontsize=fontsize)
        plot_point(mou.r_center[t_ind],'CM' if show_labels else '',fmt='v',color=colors[1],markersize=3,va='top',ha='left',fontsize=fontsize)
        plot_arrow(numpy.zeros(2),mou.r_center[t_ind],'',color=numpy.insert(colors[1][:3],3,zero_vec_alpha),fontsize=fontsize)
        plot_arrow(mou.r_center[t_ind],mou.r_nose[t_ind],vec_label,labelpos=labelpos,color=colors[2],arrowArgs=dict(head_width=1),fontsize=vec_fontsize,**vec_text_args)


    if TEST_ARENA_COORD:
        mouse = tran.fill_trajectory_nan_gaps(io.load_trial_file('./experiments/relative_target/mouse_10/mpos_06Sept2019_trial_2_startloc_SE_day_6.mat'))
        pltt.plot_arena_sketch(mouse,showAllEntrances=False)
        plot_point(mouse.r_arena_center,'arena center',fmt='o',color='m',va='bottom',ha='left',fontsize=7)
        plot_point(numpy.zeros(2),'pic center',fmt='o',color='k',va='bottom',ha='right',fontsize=7)
        plot_point(mouse.r_start,'start',fmt='o',color='c',va='bottom',ha='left',fontsize=7)
        plot_arrow(numpy.zeros(2),mouse.r_start,'',color='c',arrowArgs=dict(alpha=0.2))
        plot_point(mouse.r_target,'target',fmt='o',color='r',va='top',ha='left',fontsize=7)
        plot_arrow(numpy.zeros(2),mouse.r_target,'',color='r',arrowArgs=dict(alpha=0.2))
        plot_arrow(mouse.r_start,mouse.r_target,r'$\vec{f}$',color='r',fontsize=16,labelpos='center')
        colors = plt.get_cmap('tab10')(numpy.linspace(0,1,10))
        plot_mouse(mouse,5000,colors[:3],fontsize=7,vec_label=r'$\vec{m}_1$',vec_fontsize=16,vec_text_args=dict())
        plot_mouse(mouse,7500,colors[3:6],fontsize=7,vec_label=r'$\vec{m}_2$',vec_fontsize=16,vec_text_args=dict(va='top',ha='right'))
        plot_mouse(mouse,8000,colors[6:9],fontsize=7,vec_label=r'$\vec{m}_3$',vec_fontsize=16,vec_text_args=dict(va='top',ha='left'))
        plot_arrow(mouse.r_center[5000],mouse.r_target,r'$\vec{f}_{c,1}$',color='darkgreen',fontsize=12,labelpos='center',va='top',ha='left',arrowArgs=dict(head_width=1,alpha=0.5))
        plot_arrow(mouse.r_center[7500],mouse.r_target,r'$\vec{f}_{c,2}$',color='chocolate',fontsize=12,labelpos='center',va='bottom',ha='right',arrowArgs=dict(head_width=1,alpha=0.5))
        plot_arrow(mouse.r_center[8000],mouse.r_target,r'$\vec{f}_{c,3}$',color='orange',fontsize=12,labelpos='center',va='top',ha='left',arrowArgs=dict(head_width=1,alpha=0.5))
        #pltt.plot_mouse_trajectory(plt.gca(),mouse,'nose',show_start=False,show_target=False,color=colors[4])
        plt.show()


    if TEST_VECTOR_ANGLES:
        mouse = tran.fill_trajectory_nan_gaps(io.load_trial_file('./experiments/relative_target/mouse_10/mpos_06Sept2019_trial_2_startloc_SE_day_6.mat'))
        rad_to_deg = lambda th: th * 180.0 / numpy.pi
        # mouse instants
        t1 = 5000
        t2 = 7500
        t3 = 8000
        deviation_to_abs_food = tran.calc_mouse_deviation(mouse,absolute_food_vec=True)
        angle_to_abs_food = numpy.arccos(deviation_to_abs_food)
        angle_to_rel_food = tran.calc_mouse_deviation(mouse,absolute_food_vec=False,return_angle=True)
        R1_abs = misc.RotateTransf( [], [], numpy.zeros(2), angle=angle_to_abs_food[t1] )
        R2_abs = misc.RotateTransf( [], [], numpy.zeros(2), angle=angle_to_abs_food[t2] )
        R3_abs = misc.RotateTransf( [], [], numpy.zeros(2), angle=angle_to_abs_food[t3] )
        R1_rel = misc.RotateTransf( [], [], numpy.zeros(2), angle=angle_to_rel_food[t1] )
        R2_rel = misc.RotateTransf( [], [], numpy.zeros(2), angle=angle_to_rel_food[t2] )
        R3_rel = misc.RotateTransf( [], [], numpy.zeros(2), angle=angle_to_rel_food[t3] )

        ax = pltt.plot_arena_sketch(mouse,showAllEntrances=False,arenaPicture=False,showHoles=False,showArenaCircle=False)
        ax.axhline(0,color='k',linewidth=0.4)
        ax.axvline(0,color='k',linewidth=0.4)
        plot_point(numpy.zeros(2),'',fmt='o',color='k')
        colors = plt.get_cmap('tab10')(numpy.linspace(0,1,10))
        #plot_arrow(mouse.r_start,mouse.r_target,'',color='r',fontsize=16,labelpos='center',arrowArgs=dict(alpha=0.2))
        #plot_arrow(mouse.r_center[t1],mouse.r_nose[t1],r'$\vec{m}_1$',color=colors[0],arrowArgs=dict(alpha=0.2,head_width=1.3),fontsize=16,labelpos='center')
        plot_arrow(numpy.zeros(2),mouse.r_target-mouse.r_start,r'$\vec{f}$',color='r',fontsize=16,labelpos='center')
        plot_arrow(numpy.zeros(2),10*(mouse.r_nose[t1]-mouse.r_center[t1]),r'$\vec{m}_1$',color=colors[0],fontsize=16,labelpos='center',va='bottom',ha='left')
        plot_arrow(numpy.zeros(2),10*(mouse.r_nose[t2]-mouse.r_center[t2]),r'$\vec{m}_2$',color=colors[1],fontsize=16,labelpos='center',va='top',ha='right')
        plot_arrow(numpy.zeros(2),10*(mouse.r_nose[t3]-mouse.r_center[t3]),r'$\vec{m}_3$',color=colors[2],fontsize=16,labelpos='center',va='top',ha='left')
        plot_arrow(numpy.zeros(2),R1_abs(mouse.r_target-mouse.r_start),'$R(%.2f^{\\rm o})\\vec{f}$'%rad_to_deg(R1_abs.theta),color=colors[3],fontsize=16,labelpos='end')
        plot_arrow(numpy.zeros(2),R2_abs(mouse.r_target-mouse.r_start),'$R(%.2f^{\\rm o})\\vec{f}$'%rad_to_deg(R2_abs.theta),color=colors[4],fontsize=16,labelpos='center',va='top',ha='right')
        plot_arrow(numpy.zeros(2),R3_abs(mouse.r_target-mouse.r_start),'$R(%.2f^{\\rm o})\\vec{f}$'%rad_to_deg(R3_abs.theta),color=colors[5],fontsize=16,labelpos='end')
        ax.set_title('Absolute food vector')

        colors = plt.get_cmap('tab10')(numpy.linspace(0,1,10))
        ax = pltt.plot_arena_sketch(mouse,showAllEntrances=False,arenaPicture=False,showHoles=False,showArenaCircle=False)
        ax.axhline(0,color='k',linewidth=0.4)
        ax.axvline(0,color='k',linewidth=0.4)
        plot_point(numpy.zeros(2),'',fmt='o',color='k')
        plot_arrow(numpy.zeros(2),mouse.r_target-mouse.r_center[t1],r'$\vec{f}_1$',color='darkturquoise',fontsize=16,labelpos='center',va='top',ha='right')
        plot_arrow(numpy.zeros(2),10*(mouse.r_nose[t1]-mouse.r_center[t1]),r'$\vec{m}_1$',color=colors[0],fontsize=16,labelpos='end',va='bottom',ha='left')
        plot_arrow(numpy.zeros(2),2*R1_rel(mouse.r_target-mouse.r_center[t1]),'$R(%.2f^{\\rm o})\\vec{f}_1$'%rad_to_deg(R1_rel.theta),color=colors[6],fontsize=16,labelpos='end')
        ax.set_title('Relative food vector -- position 1')

        ax = pltt.plot_arena_sketch(mouse,showAllEntrances=False,arenaPicture=False,showHoles=False,showArenaCircle=False)
        ax.axhline(0,color='k',linewidth=0.4)
        ax.axvline(0,color='k',linewidth=0.4)
        plot_point(numpy.zeros(2),'',fmt='o',color='k')
        plot_arrow(numpy.zeros(2),mouse.r_target-mouse.r_center[t2],r'$\vec{f}_2$',color='orange',fontsize=16,labelpos='center',va='top',ha='left')
        plot_arrow(numpy.zeros(2),10*(mouse.r_nose[t2]-mouse.r_center[t2]),r'$\vec{m}_2$',color='sienna',fontsize=16,labelpos='end',va='top',ha='right')
        plot_arrow(numpy.zeros(2),2*R2_rel(mouse.r_target-mouse.r_center[t2]),'$R(%.2f^{\\rm o})\\vec{f}_2$'%rad_to_deg(R2_rel.theta),color=colors[7],fontsize=16,labelpos='end',va='top',ha='right')
        ax.set_title('Relative food vector -- position 1')

        ax = pltt.plot_arena_sketch(mouse,showAllEntrances=False,arenaPicture=False,showHoles=False,showArenaCircle=False)
        ax.axhline(0,color='k',linewidth=0.4)
        ax.axvline(0,color='k',linewidth=0.4)
        plot_point(numpy.zeros(2),'',fmt='o',color='k')
        plot_arrow(numpy.zeros(2),mouse.r_target-mouse.r_center[t3],r'$\vec{f}_3$',color='mediumspringgreen',fontsize=16,labelpos='center',va='bottom',ha='right')
        plot_arrow(numpy.zeros(2),10*(mouse.r_nose[t3]-mouse.r_center[t3]),r'$\vec{m}_3$',color=colors[2],fontsize=16,labelpos='end',va='top',ha='left')
        plot_arrow(numpy.zeros(2),2*R3_rel(mouse.r_target-mouse.r_center[t3]),'$R(%.2f^{\\rm o})\\vec{f}_3$'%rad_to_deg(R3_rel.theta),color=colors[8],fontsize=16,labelpos='end')
        ax.set_title('Relative food vector -- position 1')
        plt.show()


    if TEST_FIND_TRAJECTORY:
        points = numpy.array([(-23.5,-36.8),(17.3,-37.3)]) # tries to find these points in all trajectories of mouse 10
        hole_horizon = 2.0 # cm
        tr_found,p_found,kAB,tAB,rAB,trial = tran.find_trajectory('./experiments/relative_target/mouse_10', points, hole_horizon, find_any_point=False, points_in_temporal_order=True)
        for k in range(len(tr_found)):
            ax = pltt.plot_arena_sketch(tr_found[k],showAllEntrances=False)
            pltt.plot_mouse_trajectory(ax,tr_found[k],'nose',show_start=True,show_target=True,color=plt.get_cmap('copper'),line_gradient_variable='time')
            pltt.plot_trajectory_points(p_found[k],ax=ax,linestyle='none',marker='o',markersize=10,linewidth=5,fillstyle='none',color='r',label='Points found')
            ax.set_title('Found trial: %s; time delay: %.2f' % (trial[k],tAB[k]))
        plt.show()


    if TEST_COORD_HISTOGRAM:
        # import all trials of mouse 10 into the m list, sorted by trial, such that m[0] -> trial # 1
        align_vector = numpy.array( (0,1) )
        m = misc.rotate_trial_file(io.load_trial_file('./experiments/relative_target/mouse_*',sort_by_trial=True,fix_nan=True,remove_after_food=True,load_only_training_sessions_relative_target=True),align_vector,return_only_track=True)

        # making the histogram for trial #1, i.e. m[0]
        # the edges of the histogram, as defined by the numpy.histogram function
        # https://numpy.org/doc/stable/reference/generated/numpy.histogram.html
        n_bins = 25 # number of bins in the histogram, you should vary this parameter to check what looks better
        x_min = numpy.min([numpy.min(mouse.r_nose[:,0]) for mouse in m])
        x_max = numpy.max([numpy.max(mouse.r_nose[:,0]) for mouse in m])
        print('x_min = {:g}'.format(x_min))
        print('x_max = {:g}'.format(x_max))
        x_edges = numpy.linspace(x_min, x_max, n_bins+1)

        # calculating P(x)
        # the parameter density tells the numpy.histogram function that it should return a "probability density function" (pdf)
        P_x,_ = numpy.histogram(m[0].r_nose[:,0], bins=x_edges, density=True)

        # the mid points of each histogram bin
        x_mid = x_edges[:-1] + numpy.diff(x_edges)/2
        print('x_mid = ')
        print(x_mid)

        plt.plot(x_mid,P_x,'-o',label='mouse %s, trial %s'%(m[0].mouse_number,m[0].trial))
        plt.xlabel('x (cm)')
        plt.ylabel('P(x)')
        plt.legend()
        plt.show()


    if TEST_STEPPROB_PATH:
        S = io.load_step_probability_file('step_prob_matrices/relative_target/independent/ntrials_16/stopfood/Pinit025/stepmat_nose_L_11_nstages_16_ntrials_16_Pinit_0.25_indept_stopfood.mat')
        print('loaded')



    if TEST_ARENA_PICTURES_COMPARE:
        arena_pic1 = 'arena_picture/BKGDimage-pilot.png'
        arena_pic2 = 'arena_picture/jun-jul-aug-nov-2021/BKGDimage-arenaB.png'
        arena_pic3 = 'arena_picture/jun-jul-aug-nov-2021/BKGDimage-arenaB_cropped.png'
        px_unit = 1.0/plt.rcParams['figure.dpi']
        aimg1 = mpimg.imread(arena_pic1)
        aimg2 = mpimg.imread(arena_pic2)
        aimg3 = mpimg.imread(arena_pic3)
        alpha_x = 0.5208
        alpha_y = 0.5218
        fig1,ax1 = plt.subplots(nrows=1,ncols=1,figsize=(aimg1.shape[1]*px_unit,aimg1.shape[0]*px_unit))
        fig2,ax2 = plt.subplots(nrows=1,ncols=1,figsize=(alpha_x*aimg2.shape[1]*px_unit,alpha_y*aimg2.shape[0]*px_unit))
        fig3,ax3 = plt.subplots(nrows=1,ncols=1,figsize=(aimg3.shape[1]*px_unit,aimg3.shape[0]*px_unit))
        ax1.set_position([0,0,1,1])
        ax2.set_position([0,0,1,1])
        ax3.set_position([0,0,1,1])
        ax1.imshow(aimg1, extent=[-97.0, 97.0, -73.0, 73.0])
        ax2.imshow(aimg2, extent=[-151.26, 150.94, -84.66, 85.29])
        ax3.imshow(aimg3, extent=[-104.16, 88.66, -69.10, 75.13])
        ax1.plot(0,0,'+r')
        ax2.plot(0,0,'+m')
        ax3.plot(0,0,'xr')
        plt.show()


    if TEST_PLOT_ALL_ARENA_CENTERS:
        px_unit = 1.0/plt.rcParams['figure.dpi']
        arena_pic_dir = 'arena_picture'
        arena_pic = [
            ('BKGDimage-pilot.png',[-97.0, 97.0, -73.0, 73.0]),
            ('dec-2019/BKGDimage-localCues.png',[-129.58, 129.58, -73.03, 73.03]),
            ('mar-may-2021/BKGDimage-localCues_clear.png',[-151.06, 150.43, -84.23, 84.86]),
            ('mar-may-2021/BKGDimage-localCues_Letter.png',[-151.06, 150.43, -84.23, 84.86]),
            ('mar-may-2021/BKGDimage-localCues_LetterTex.png',[-151.06, 150.43, -84.23, 84.86]),
            ('jun-jul-aug-nov-2021/BKGDimage_3LocalCues.png',[-151.26, 150.94, -84.66, 85.29]),
            ('jun-jul-aug-nov-2021/BKGDimage_3LocalCues_Reverse.png',[-151.26, 150.94, -84.66, 85.29]),
            ('jun-jul-aug-nov-2021/BKGDimage_asymm.png',[-151.26, 150.94, -84.66, 85.29]),
            ('jun-jul-aug-nov-2021/BKGDimage_asymmRev.png',[-151.26, 150.94, -84.66, 85.29]),
            ('jun-jul-aug-nov-2021/BKGDimage-arenaB.png',[-151.26, 150.94, -84.66, 85.29]),
            ('jun-jul-aug-nov-2021/BDGDimage_arenaB_visualCues.png',[-151.26, 150.94, -84.66, 85.29])
        ]
        for pic_name,ext in arena_pic:
            print('processing %s'%pic_name)
            aimg1 = mpimg.imread(os.path.join(arena_pic_dir,pic_name))
            w = aimg1.shape[1]*px_unit
            h = aimg1.shape[0]*px_unit
            fig1,ax1 = plt.subplots(nrows=1,ncols=1,figsize=(w,h))
            fig1.patch.set_facecolor('r')
            ax1.set_frame_on(False)
            ax1.set_axis_off()
            #dx = 1.0*px_unit
            #ax1.set_position([(-2.0*px_unit/w),0.0,1.0+dx,1.0])
            ax1.set_position([0.0,0.0,1.0,1.0])
            ax1.imshow(aimg1, extent=ext)
            #ax1.set_xlim((ext[0],ext[1]+0.5))
            ax1.plot(0,0,'xr')
            ax1.hlines([-10,10],ext[0],ext[1],colors='r',linestyles='dashed')
            ax1.vlines([-10,10],ext[2],ext[3],colors='r',linestyles='dashed')
            new_name = os.path.join(arena_pic_dir,pic_name.replace('.png','_center.png'))
            print('... saving %s'%new_name)
            plt.savefig(new_name,format='png',dpi=int(1.0/px_unit))
            plt.close(fig1)
        


    if TEST_PREPROCESS_2TARGET:
        arena_pic_dir = 'arena_picture'
        trial_dir = '../EthovisionPathAnalysis/Raw Trial Data/2021-06-22_Raw Trial Data'
        #trial_dir = 'D:/Dropbox/p/uottawa/data/animal_trajectories/EthovisionPathAnalysis/Raw Trial Data/2019-09-06_Raw Trial Data/'
        trial_files = plib.get_trial_files(trial_dir,file_ptrn='*-Trial*.xlsx')
        n_rows_skip = plib.get_n_header_rows(trial_files[20][1])
        trial_idx,fname = trial_files[20]
        fheader = plib.read_trial_header(fname,trial_idx,arena_pic_dir,nrows_header=n_rows_skip-1)
        d = plib.read_trial_data(fname,nrows_header=n_rows_skip)
        
        px_unit = 1.0/plt.rcParams['figure.dpi']
        arena_pic3 = 'arena_picture/jun-jul-aug-nov-2021/BKGDimage-arenaB_cropped.png'
        aimg3 = mpimg.imread(arena_pic3)

        print('testing raw plot')
        fig3,ax3 = plt.subplots(nrows=1,ncols=1,figsize=(aimg3.shape[1]*px_unit,aimg3.shape[0]*px_unit))
        ax3.set_position([0,0,1,1])
        ax3.imshow(aimg3, extent=[fheader.arena_pic_left, fheader.arena_pic_right, fheader.arena_pic_bottom, fheader.arena_pic_top])
        ax3.plot(d.r_nose[:,0],d.r_nose[:,1],'-',c='tab:blue')
        ax3.plot(fheader.r_target[0],fheader.r_target[1],'o',c='tab:red',fillstyle='none')
        ax3.plot(fheader.r_arena_holes[:,0],fheader.r_arena_holes[:,1],'s',c='tab:green',fillstyle='none')
        plt.show()

        print('testing predefined functions plot')
        track = misc.structtype(**fheader,**d)
        ax=pltt.plot_arena_sketch(track,arenaPicture=True)
        ax=pltt.plot_arena_sketch(track,arenaPicture=False,ax=ax)
        pltt.plot_mouse_trajectory(ax, track)
        plt.show()


    if TEST_ARENA_SHIFT_PIC:
        img_ref = 'arena_picture/BKGDimage-pilot.png'
        img     = 'arena_picture/jun-jul-aug-nov-2021/BKGDimage-arenaB.png'

        c = numpy.array((496, 274))
        c_ref = numpy.array((345.05266804, 246.48789))

        #img_shift = plib.align_arena_center_and_crop(img_ref,img,c_ref,c)
        dx_correct = -2
        dy_correct = -4
        dx_ref = [-97.0,97.0]
        dy_ref = [-73.0,73.0]
        dx = numpy.asarray((-151.26, 150.94))
        dy = numpy.asarray((-84.66, 85.29))
        img = edged.transform_pic_to_match_distance(img_ref,img,dx_ref,dy_ref,dx,dy)
        img_shift,img_extent = edged.align_arena_center_and_crop(img_ref,img,c_ref,c,bgcolor_rgb=None,dx_correct_px=dx_correct,dy_correct_px=dy_correct,xRange_world_ref=dx_ref,xRange_world=dx,yRange_world_ref=dy_ref,yRange_world=dy,showCroppedRegion=True)
        img_shift.show()
    
    if TEST_ARENA_ALIGNMENT:
        track = io.load_trial_file('./debug_preprocess/mouse_38/mpos_16Jul2021_trial_1_startloc_SE_day_6.mat ./debug_preprocess/mouse_11/mpos_06Sept2019_trial_1_startloc_NE_day_6.mat debug_preprocess/mouse_6/mpos_23May2019_trial_2_startloc_SE_day_6.mat debug_preprocess/mouse_34/mpos_22Jun2021_trial_2_startloc_SE_day_6.mat'.split(' '))

        ax_list=[]
        for tr in track:
            arena_pic = plib.get_cropped_arena_picture(tr,bgcolor_rgba=(1,1,1,1))
            ax = pltt.plot_arena_sketch(tr,showAllEntrances=True,arenaPicture=arena_pic,showHoles=True,holesColor='tab:red')
            ax.set_title('Mouse %s trial %s'%(tr.mouse_number,tr.trial))
            ax_list.append(ax)
        
        for ax in ax_list:
            pltt.plot_mouse_trajectory(ax,track,mouse_part='nose')
        
        #pltt.plot_mouse_trajectory(ax,track,mouse_part='nose')
        #ax.plot(0,0,'ok',markersize=6,zorder=1003,label='origin')
        #plt.legend(loc='upper left',bbox_to_anchor=(-0.05,1))


        #color_map = plt.get_cmap('plasma')
        #line_color_feat='time'
        #pltt.plot_mouse_trajectory(ax,track,'nose',color=color_map,line_gradient_variable=line_color_feat,linewidth=2)

        plt.show()
        print('ok')


    if TEST_FIND_CLUSTERS_ARRAY:
        img = numpy.tile(numpy.array([ [0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
                                       [0,0,0,0,0,1,1,1,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0],
                                       [0,0,0,0,0,1,1,1,0,0,0,0,0,0,1,1,1,1,1,0,1,1,1,0,0,0,0,0,0,0,0],
                                       [0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,1,1,1,0,0,0,0,0,0,0],
                                       [1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,1,1,1,0,0,0,0],
                                       [1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,1,1,1,1,0,0,0,0],
                                       [1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,1,1,1,1,0,0,0,0],
                                       [0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
                                       [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1],
                                       [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1],
                                       [0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1],
                                       [0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
                                       ]).reshape(12,31,1),(1,1,3))*255
        
        C = edged.find_clusters(img,0.5)
        
        plt.imshow(img)
        ax=plt.gca()
        for c in C:
            cluster = plt.Circle(c[:2],c[2],facecolor='none',edgecolor='r')
            ax.add_patch(cluster)

        plt.show()

    if TEST_FIND_ARENA_HOLES:
        img = PIL.Image.open('arena_picture/debug_crop_arena/imtest_find_holes.png')
        C = edged.find_clusters(img,threshold=0.5,find_less_than_threshold=True)
        plt.imshow(numpy.array(img),cmap='Greys',interpolation='nearest')
        ax=plt.gca()
        for c in C:
            cluster = plt.Circle(c[:2],c[2],facecolor='none',edgecolor='r')
            ax.add_patch(cluster)
        plt.show()
    
    if TEST_ARENA_IMG_EXTENT:
        arena_pic = [
            ('arena_picture/dec-2019/BKGDimage-localCues.png',                      [-129.58, 129.58,-73.03, 73.03]),
            ('arena_picture/mar-may-2021/BKGDimage-localCues_clear.png',            [-151.06, 150.43,-84.23, 84.86]),
            ('arena_picture/mar-may-2021/BKGDimage-localCues_Letter.png',           [-151.06, 150.43,-84.23, 84.86]),
            ('arena_picture/mar-may-2021/BKGDimage-localCues_LetterTex.png',        [-151.06, 150.43,-84.23, 84.86]),
            ('arena_picture/jun-jul-aug-nov-2021/BKGDimage_3LocalCues.png',         [-151.26, 150.94,-84.66, 85.29]),
            ('arena_picture/jun-jul-aug-nov-2021/BKGDimage_3LocalCues_Reverse.png', [-151.26, 150.94,-84.66, 85.29]),
            ('arena_picture/jun-jul-aug-nov-2021/BKGDimage_asymm.png',              [-151.26, 150.94,-84.66, 85.29]),
            ('arena_picture/jun-jul-aug-nov-2021/BKGDimage_asymmRev.png',           [-151.26, 150.94,-84.66, 85.29]),
            ('arena_picture/jun-jul-aug-nov-2021/BKGDimage-arenaB.png',             [-151.26, 150.94,-84.66, 85.29]),
            ('arena_picture/jun-jul-aug-nov-2021/BDGDimage_arenaB_visualCues.png',  [-151.26, 150.94,-84.66, 85.29])
        ]
        for pic_file,img_extent in arena_pic:
            hole_file = pic_file.replace('.png','_holes.txt')
            holes = numpy.loadtxt(hole_file,comments='#',delimiter=',')
            img_extent_cropped = io.get_img_extent_from_header(hole_file,hchar='#')
            arena_img = mpimg.imread(pic_file)
            plt.figure()
            ax=plt.gca()
            ax.imshow(arena_img, extent=img_extent)
            pltt.plot_vertical_lines(img_extent_cropped[:2],ax=ax,  linestyle='-',color='y',linewidth=1.5)
            pltt.plot_horizontal_lines(img_extent_cropped[2:],ax=ax,linestyle='-',color='c',linewidth=1.5)
            ax.plot(holes[:,1],holes[:,2],'o',fillstyle='none',color='r',markersize=5)
        plt.show()

    if TEST_HOLE_DETECTION_EXTENT_POSITION:
        arena_pic = [
            'arena_picture/dec-2019/BKGDimage-localCues_cropped.png'#,
            'arena_picture/mar-may-2021/BKGDimage-localCues_clear_cropped.png',
            'arena_picture/mar-may-2021/BKGDimage-localCues_Letter_cropped.png',
            'arena_picture/mar-may-2021/BKGDimage-localCues_LetterTex_cropped.png',
            'arena_picture/jun-jul-aug-nov-2021/BDGDimage_arenaB_visualCues_cropped.png',
            'arena_picture/jun-jul-aug-nov-2021/BKGDimage_3LocalCues_cropped.png',
            'arena_picture/jun-jul-aug-nov-2021/BKGDimage_3LocalCues_Reverse_cropped.png',
            'arena_picture/jun-jul-aug-nov-2021/BKGDimage_asymm_cropped.png',
            'arena_picture/jun-jul-aug-nov-2021/BKGDimage_asymmRev_cropped.png',
            'arena_picture/jun-jul-aug-nov-2021/BKGDimage-arenaB_cropped.png'
        ]
        for pic_file in arena_pic:
            hole_file = pic_file.replace('_cropped.png','_holes.txt')
            holes = numpy.loadtxt(hole_file,comments='#',delimiter=',')
            #holes = numpy.column_stack((numpy.zeros(100),plib.get_arena_hole_coord()))
            img_extent = io.get_img_extent_from_header(hole_file,hchar='#')
            arena_img = mpimg.imread(pic_file)
            plt.figure()
            ax=plt.gca()
            ax.imshow(arena_img, extent=img_extent)
            ax.plot(holes[:,1],holes[:,2],'o',fillstyle='none',color='r',markersize=5)
        plt.show()
    
    if TEST_FIND_SELF_INTERSECTIONS_MOUSE:
        track = io.load_trial_file('experiments/relative_target/mouse_9/mpos_06Sept2019_trial_14_startloc_SW_day_12.mat',fix_nan=True)
        t_inter,r_inter = tran.find_self_intersections(track,mouse_part='nose',return_intersec_position=True)
        ax = pltt.plot_arena_sketch(track, arenaPicture=True, showHoles=False, showArenaCircle=False)
        pltt.plot_mouse_trajectory(ax,track,'nose',line_gradient_variable='time')
        print(' *** self-intersection times (s)')
        print(t_inter)
        r_inter = numpy.array(r_inter)
        ax.plot(r_inter[:,0],r_inter[:,1],'or',markersize=6,linewidth=1.5,fillstyle='none')
        plt.show()
    
    if TEST_FIND_SELF_INTERSECTIONS:
        # drawing a loop for testing
        theta = numpy.concatenate((numpy.linspace(8*numpy.pi/6,2*numpy.pi,51),numpy.linspace(0,4*numpy.pi/6,50)[1:]))
        r = numpy.column_stack((numpy.tan(theta/2.0)*numpy.cos(theta),numpy.tan(theta/2.0)*numpy.sin(theta)))
        t_inter,r_inter = misc.find_self_intersection_jit(r,numpy.arange(theta.size))
        plt.figure()
        ax = plt.gca()
        ax.plot(r[:,0],r[:,1],':sb',markersize=3,fillstyle='none')
        print(t_inter)
        ax.plot(r_inter[:,0],r_inter[:,1],'or',markersize=6,linewidth=1.5,fillstyle='none')

        # drawing two loops for testing
        theta   = numpy.concatenate((numpy.linspace(8*numpy.pi/6,2*numpy.pi,51),numpy.linspace(0,4*numpy.pi/6,50)[1:]))
        r1      = numpy.column_stack((numpy.tan(theta/2.0)*numpy.cos(theta),numpy.tan(theta/2.0)*numpy.sin(theta)))
        r1[:,1] = r1[:,1] - numpy.max(r1[:,1])
        r2      = r1.copy()
        r2[:,1] = -r2[:,1]
        r       = numpy.row_stack((r1,numpy.flipud(r2)))
        t_inter,r_inter = misc.find_self_intersection_jit(r,numpy.arange(theta.size))
        plt.figure()
        ax = plt.gca()
        ax.plot(r[:,0],r[:,1],':sb',markersize=3,fillstyle='none')
        print(t_inter)
        ax.plot(r_inter[:,0],r_inter[:,1],'or',markersize=6,linewidth=1.5,fillstyle='none')
        plt.show()
    
    if TEST_REMOVE_SLOW_PARTS:
        track  = io.load_trial_file('experiments/relative_target/mouse_9/mpos_06Sept2019_trial_14_startloc_SW_day_12.mat',fix_nan=True,remove_after_food=True)
        track2,v_th = tran.remove_slow_parts(track,'ampv',0.2,return_threshold=True)
        ax = pltt.plot_arena_sketch(track, arenaPicture=True, showHoles=False, showArenaCircle=False)
        pltt.plot_mouse_trajectory(ax,track,'nose',color='b')

        #ax = pltt.plot_arena_sketch(track, arenaPicture=True, showHoles=False, showArenaCircle=False)
        pltt.plot_mouse_trajectory(ax,track2,'nose',color='r',show_start=False,show_target=False)
        ax.plot(track.r_nose[:,0],track.r_nose[:,1],'sb',label='Raw data')
        ax.plot(track2.r_nose[:,0],track2.r_nose[:,1],'or',fillstyle='none',label='Thresholded data')
        ax.set_title('Static entrance, mouse 9, trial 14')
        ax.legend(['_','_','_','_','Raw data','Thresholded data'],fontsize=16,loc='upper left',bbox_to_anchor=(0,1))

        plt.figure()
        plt.plot(track.time, track.velocity, '-b',label='Raw data')
        plt.plot(track2.time,track2.velocity,':r',label='Thresholded data')
        plt.plot(track.time,numpy.ones(track.time.size)*v_th,'--k')
        plt.xlabel('Time (s)',fontsize=16)
        plt.ylabel('Velocity (cm/s)',fontsize=16)
        plt.title('Static entrance, mouse 9, trial 14',fontsize=16)
        plt.gca().legend()
        plt.show()

    if TEST_2TARGETS_TRACK_TRIM:
        #track = io.load_trial_file('experiments/two_target_no_cues/mouse_*',file_name_expr='mpos_*trial_2_*')
        #track = io.load_trial_file('experiments/two_target_no_cues/mouse_*',file_name_expr='mpos_*trial_20_*')

        #track,trial_labels = io.load_trial_file('experiments/two_target_no_cues/mouse_*',file_name_expr='mpos_*_Probe*',fix_nan=True,group_by='trial',return_group_by_keys=True,remove_after_food=True)

        track = io.load_trial_file('experiments/two_target_no_cues/mouse_*',file_name_expr='mpos_*Probe3_*',fix_nan=True,sort_by_trial=True,return_group_by_keys=True,remove_after_food=False)
        track = plib.rotate_trial_file(track,(-1,1),True)

        hole_horizon = 10.0 # cm
        time_delay_after_food = 1.0 # sec
        track12 = tran.keep_path_between_targets(copy.deepcopy(track),return_t_in_targets=False,               hole_horizon=hole_horizon,time_delay_after_food=time_delay_after_food)
        track1 = [ tran.remove_path_after_food(copy.deepcopy(tr),tr12.r_nose[0,:],False,force_main_target=True,hole_horizon=hole_horizon,time_delay_after_food=time_delay_after_food) for tr,tr12 in zip(track,track12) ]

        panel_ind = dict(zip([33,36,57,58,35,34,59,60],range(len(track)))) # indices are chosen to match Kelly's slides
        fig,ax = plt.subplots(nrows=2,ncols=4,figsize=(18,10))
        ax = ax.flatten()
        #for i in range(2):
        #    for j in range(4):
        for k in range(len(track)):
            tr     = track[k]          #tr  = track[1][k]
            tr1    = track1[k]         #trf = track_filtered[1][k]
            tr12   = track12[k]
            ax_ind = panel_ind[int(tr.mouse_number)] if tr.trial == 'Probe2' else k
            ax[ax_ind] = pltt.plot_arena_sketch(  tr, ax=ax[ax_ind],arenaPicture=False, showHoles=True, showArenaCircle=True)
            pltt.plot_mouse_trajectory(ax[ax_ind],tr1, 'nose',show_target=True,show_alt_target=True,color='r')
            pltt.plot_mouse_trajectory(ax[ax_ind],tr12,'nose',show_target=True,show_alt_target=True,color='b')
            ax[ax_ind].set_aspect('equal','box')
            ax[ax_ind].set_title('mouse %s, trial %s'%(tr.mouse_number,tr.trial))

        plt.show()
        #track = io.load_trial_file('debug_preprocess/mouse_34/mpos_22Jun2021_trial_3_startloc_SE_day_6.mat')
        #track = io.load_trial_file('debug_preprocess/mouse_59/mpos_19Nov2021_trial_1_startloc_NE_day_6.mat')
        #track = io.load_trial_file('debug_preprocess/mouse_36/mpos_22Jun2021_trial_23_startloc_NW_day_14.mat')
        #track = io.load_trial_file('debug_preprocess/mouse_57/mpos_19Nov2021_trial_22_startloc_SW_day_13.mat')
        #ax = pltt.plot_arena_sketch(track, arenaPicture=True, showHoles=True, showArenaCircle=True, showAllEntrances=True)
        #pltt.plot_mouse_trajectory(ax,track,'nose',color='m',show_target=True,show_alt_target=True)
    
    if TEST_AVG_OVER_DISPLACEMENT:
        mouse_traj_dir = r'./experiments/two_target_no_cues/mouse_*'
        all_trials_p2_complete = io.load_trial_file(mouse_traj_dir,file_name_expr='mpos_*Probe2_*',fix_nan=True,sort_by_trial=True,return_group_by_keys=False,remove_after_food=False)
        d_food_baseline_p2 = numpy.linalg.norm(all_trials_p2_complete[0].r_target-all_trials_p2_complete[0].r_target_alt)
        x_avg,dist,x_std,x_err,x_min,x_max=tran.avg_value_over_displacement(all_trials_p2_complete, tran.calc_mouse_perp_dist_to_2target_line(all_trials_p2_complete,return_abs_value=True), d_food_baseline_p2, r0=None, n_r0_sample=10)
        print(x_avg)
        print(dist)
        print(x_std)
        print(x_err)
        print(x_min)
        print(x_max)
        print(misc.avg_of_avg(x_avg,x_std,x_err,x_min,x_max))

    if TEST_CUMULATIVE_N_CHECKED_HOLES:
        mouse_traj_dir = r'./experiments/two_target_no_cues/mouse_*'
        all_trials_p2_complete = io.load_trial_file(mouse_traj_dir,file_name_expr='mpos_*Probe2_*',fix_nan=True,sort_by_trial=True,return_group_by_keys=False,remove_after_food=False)
        _,t_targets            = tran.keep_path_between_targets(all_trials_p2_complete,return_t_in_targets=True,hole_horizon=10.0,time_delay_after_food=1.0,copy_tracks=True)
        hole_horizon = 3.0 # cm
        k = 5
        n2 = tran.calc_number_checked_holes_per_dist(all_trials_p2_complete[k],hole_horizon,threshold_method='ampv',gamma=0.1,divide_by_total_distance=True,cumulative=True)
        plt.plot(all_trials_p2_complete[k].time,n2,'-',label='cumulative density of checked holes')
        plt.plot(all_trials_p2_complete[k].time[:-1],numpy.diff(n2),'-',label='density of checked holes')
        pltt.plot_vertical_lines(t_targets[k],ax=plt.gca(),linestyle='--',color='k',label='target')
        plt.gca().set_xlabel('Time (s)')
        plt.gca().set_ylabel('Hole checking behavior')
        plt.gca().legend()
        plt.show()
    
    if TEST_PLOT_CHECKED_HOLE_DISPERSION:
        mouse_traj_dir_2t      = r'./experiments/two_target_no_cues/mouse_*'
        hole_horizon           = 10.0 # cm
        time_delay_after_food  = 1.0 # sec
        all_trials_p2_complete = io.load_trial_file(mouse_traj_dir_2t,file_name_expr='mpos_*Probe2_*',align_to_top=True,fix_nan=True,sort_by_trial=True,return_group_by_keys=False,remove_after_food=False)
        all_trials_p2          = tran.keep_path_between_targets(all_trials_p2_complete,return_t_in_targets=False,hole_horizon=hole_horizon,time_delay_after_food=time_delay_after_food,copy_tracks=True)
        all_trials_p2_rot      = plib.rotate_trial_file(copy.deepcopy(all_trials_p2),(-1,1),True)
        
        hole_horizon              = 3.0 # in cm (units is mouse.unit_r)  
        ignore_entrance_positions = False
        normalize_by              = 'sum'
        r_un_p2,r_count_p2,r_mean_p2,r_cov_p2,r_disp_p2,r_eigdir_p2 = tran.calc_number_of_checkings_per_hole(all_trials_p2_rot,hole_horizon,threshold_method='ampv',gamma=0.2,normalize_by=normalize_by,sort_result=True,ignore_entrance_positions=ignore_entrance_positions)

        is_dark_bg = True
        get_color  = lambda c_is_dark,c_not_dark: c_is_dark if is_dark_bg else c_not_dark
        fig,ax     = plt.subplots(nrows=1,ncols=1,figsize=(18,10))
        fig.patch.set_facecolor(get_color('k','w'))
        cmap_name  = 'inferno'
        point_size = 5e3
        color_red        = numpy.array((255, 66, 66,255))/255
        color_blue       = numpy.array(( 10, 30,211,255))/255
        color_bg_dark = plt.get_cmap(cmap_name)(numpy.linspace(0,1,100))[0]
        pltt.plot_arena_sketch(all_trials_p2_rot[0]    ,showHoles=False,ax=ax,bgCircleArgs=dict(fill=True,edgecolor=get_color('w','k'),facecolor=get_color(color_bg_dark,'w')),showStart=True ,startArgs=dict(marker='s',markeredgewidth=3,markersize=10,color=get_color('w','k'),label='Start',labelArgs=dict(fontsize=12,va='bottom',ha='right',color=get_color('w','k'),pad=(-4,0))))
        ax.set_title('2-targets; probe 2'  , fontsize=14, fontweight='bold', color=get_color('w','k'))
        ax.scatter(r_un_p2[:,0]    ,r_un_p2[:,1]    ,s=point_size*r_count_p2    ,edgecolors='none',c=pltt.get_gradient(cmap_name=cmap_name)(r_count_p2/numpy.max(r_count_p2)),marker='o')
        pltt.plot_point(all_trials_p2_rot[0].r_target_alt   ,fmt='o',color=color_red ,markersize=6, ax=ax, pointArgs=dict(markeredgewidth=3, label='A',labelArgs=dict(fontsize=16,va='bottom',ha='left' , fontweight='bold',color=color_red ,pad=( 2,2)  )))
        pltt.plot_point(all_trials_p2_rot[0].r_target       ,fmt='o',color=color_blue,markersize=6, ax=ax, pointArgs=dict(markeredgewidth=3, label='B',labelArgs=dict(fontsize=16,va='top'   ,ha='left' , fontweight='bold',color=color_blue,pad=( 2,0)  )))

        pltt.draw_ellipse(r_mean_p2, r_eigdir_p2, r_disp_p2, ax=ax, show_center=True, center_args=dict(markeredgewidth=3,color=get_color('w','k'),marker='x'),facecolor='none', edgecolor=get_color('w','k'), linestyle='--', linewidth=2)

        ax.autoscale()
        ax.set_aspect('equal','box')
        ax.axis('off')
        plt.show()

    if TEST_RANDOM_ENTRANCE_ALIGNMENT:
        debug_input_dir = 'debug_preprocess'
        experiment1_dir  = ['mouse_37','mouse_38','mouse_39','mouse_40']
        experiment2_dir  = ['mouse_53','mouse_54','mouse_55','mouse_56']
        all_trials_ft1,_ = io.load_trial_file([ os.path.join(debug_input_dir,md) for md in experiment1_dir  ],load_only_training_sessions_relative_target=True ,skip_15_relative_target=True ,use_extra_trials_relative_target=False,sort_by_trial=True,fix_nan=True,remove_after_food=False,align_to_top=False,group_by='trial',return_group_by_keys=True,max_trial_number=14)
        all_trials_ft2,_ = io.load_trial_file([ os.path.join(debug_input_dir,md) for md in experiment2_dir  ],load_only_training_sessions_relative_target=True ,skip_15_relative_target=True ,use_extra_trials_relative_target=False,sort_by_trial=True,fix_nan=True,remove_after_food=False,align_to_top=False,group_by='trial',return_group_by_keys=True,max_trial_number=14)

        fig,ax = plt.subplots(nrows=2,ncols=2,figsize=(10,7))
        for k,(m1,m2) in enumerate(zip(all_trials_ft1[0],all_trials_ft2[0])):
            i,j     = numpy.unravel_index(k,(2,2))
            pltt.draw_circle(m1.r_arena_center,m1.arena_diameter/2,ax=ax[i,j],linestyle='--')
            pltt.draw_circle(m2.r_arena_center,m2.arena_diameter/2,ax=ax[i,j],linestyle=':')
            pltt.plot_trajectory_points(  m1.r_arena_holes , ax=ax[i,j], marker='s', color='r', linestyle='none', fillstyle='none',markersize=3)
            pltt.plot_trajectory_points(  m2.r_arena_holes , ax=ax[i,j], marker='d', color='b', linestyle='none', fillstyle='none',markersize=3)
            pltt.plot_point(m1.r_start,'%s m%s'%(m1.start_location,m1.mouse_number),'^',color='m',markersize=10,ax=ax[i,j])
            pltt.plot_point(m2.r_start,'%s m%s'%(m2.start_location,m2.mouse_number),'v',color='m',markersize=10,ax=ax[i,j])
            ax[i,j].set_title('%s\n%s'%(m1.get_info(),m2.get_info()))
            ax[i,j].autoscale()
            ax[i,j].set_aspect('equal','box')
            ax[i,j].axis('off')

        plt.show()


    if TEST_DISTORT_TRANSFORM_RANDOM_ENTRANCE:
        debug_input_dir = 'debug_preprocess'
        experiment1_dir = ['mouse_37','mouse_53']
        all_trials_ft   = io.load_trial_file([ os.path.join(debug_input_dir,md) for md in experiment1_dir  ],load_only_training_sessions_relative_target=True ,skip_15_relative_target=True ,use_extra_trials_relative_target=False,sort_by_trial=True,fix_nan=True,remove_after_food=False,align_to_top=False,max_trial_number=1)

        m1,m2    = all_trials_ft[0],all_trials_ft[1]
        m2transf = plib.apply_distort_transform(m2,copy_track=True)

        fig,ax = plt.subplots(nrows=1,ncols=2,figsize=(10,7))

        pltt.draw_circle(m1.r_arena_center,m1.arena_diameter/2,ax=ax[0],linestyle='--')
        pltt.draw_circle(m2.r_arena_center,m2.arena_diameter/2,ax=ax[0],linestyle=':')
        pltt.plot_trajectory_points(  m1.r_arena_holes , ax=ax[0], marker='s', color='r', linestyle='none', fillstyle='none',markersize=3, label=m1.exper_date)
        pltt.plot_trajectory_points(  m2.r_arena_holes , ax=ax[0], marker='d', color='b', linestyle='none', fillstyle='none',markersize=3, label=m2.exper_date)
        pltt.plot_point(m1.r_start,'%s m%s'%(m1.start_location,m1.mouse_number),'^',color='m',markersize=10,ax=ax[0])
        pltt.plot_point(m2.r_start,'%s m%s'%(m2.start_location,m2.mouse_number),'v',color='m',markersize=10,ax=ax[0])
        ax[0].set_title('hole position')
        ax[0].legend(loc='lower right', bbox_to_anchor=(1.1, 1))
        ax[0].autoscale()
        ax[0].set_aspect('equal','box')
        ax[0].axis('off')

        pltt.draw_circle(      m1.r_arena_center,      m1.arena_diameter/2,ax=ax[1],linestyle='--')
        pltt.draw_circle(m2transf.r_arena_center,m2transf.arena_diameter/2,ax=ax[1],linestyle=':')
        pltt.plot_trajectory_points(      m1.r_arena_holes , ax=ax[1], marker='s', color='r', linestyle='none', fillstyle='none',markersize=3, label=      m1.exper_date)
        pltt.plot_trajectory_points(m2transf.r_arena_holes , ax=ax[1], marker='d', color='b', linestyle='none', fillstyle='none',markersize=3, label=m2transf.exper_date+' transformed')
        pltt.plot_point(      m1.r_start,'%s m%s'%(      m1.start_location,      m1.mouse_number),'^',color='m',markersize=10,ax=ax[1])
        pltt.plot_point(m2transf.r_start,'%s m%s'%(m2transf.start_location,m2transf.mouse_number),'v',color='m',markersize=10,ax=ax[1])
        ax[1].set_title('hole position')
        ax[1].legend(loc='lower right', bbox_to_anchor=(1.1, 1))
        ax[1].autoscale()
        ax[1].set_aspect('equal','box')
        ax[1].axis('off')

        plt.savefig('arena_picture/distort/arenas_experiments_16Jul2021_15Nov2021_match.png',format='png',dpi=300,bbox_inches='tight')
        
        plt.show()

    if TEST_GENERATE_RANDOM_ENTRANCE_ALIGN_PLOTS:
        debug_input_dir = 'debug_preprocess'
        experiment1_dir  = ['mouse_37','mouse_38','mouse_39','mouse_40']
        experiment2_dir  = ['mouse_53','mouse_54','mouse_55','mouse_56']
        all_trials_ft1,_ = io.load_trial_file([ os.path.join(debug_input_dir,md) for md in experiment1_dir  ],load_only_training_sessions_relative_target=True ,skip_15_relative_target=True ,use_extra_trials_relative_target=False,sort_by_trial=True,fix_nan=True,remove_after_food=False,align_to_top=False,group_by='trial',return_group_by_keys=True,max_trial_number=14)
        all_trials_ft2,_ = io.load_trial_file([ os.path.join(debug_input_dir,md) for md in experiment2_dir  ],load_only_training_sessions_relative_target=True ,skip_15_relative_target=True ,use_extra_trials_relative_target=False,sort_by_trial=True,fix_nan=True,remove_after_food=False,align_to_top=False,group_by='trial',return_group_by_keys=True,max_trial_number=14)

        m1,m2 = all_trials_ft1[0][0],all_trials_ft2[0][0]
        fig_w,fig_h = 10,7
        arena_wh = m1.arena_picture_wh #get_arena_picture_file_width_height()
        ax_w = 1.2
        ax_hw_ratio = arena_wh[1] / arena_wh[0] # h and w of the arena_picture
        ax_h = ax_w * ax_hw_ratio

        rect_p0 = m1.r_arena_center - m1.arena_diameter/2-5
        rect_L  = m1.arena_diameter+10
        rect_p1 = rect_p0 + numpy.array((rect_L,rect_L))

        fig,ax = plt.subplots(nrows=1,ncols=1,figsize=(fig_w,fig_h))
        pltt.draw_circle(m1.r_arena_center,m1.arena_diameter/2,ax=ax,linestyle='--',edgecolor='k')
        pltt.draw_circle(m2.r_arena_center,m2.arena_diameter/2,ax=ax,linestyle=':' ,edgecolor=(0,0,0,0))
        pltt.draw_rectangle(rect_p0, rect_L, rect_L,ax=ax,linestyle='-',edgecolor='g')
        pltt.plot_trajectory_points(  m1.r_arena_holes ,       ax=ax, marker='s', color='r',       linestyle='none', fillstyle='none',markersize=3)
        pltt.plot_trajectory_points(  m2.r_arena_holes ,       ax=ax, marker='d', color=(0,0,0,0), linestyle='none', fillstyle='none',markersize=3)
        pltt.plot_point(m1.r_arena_center,'','o',color='m',       markersize=2,ax=ax,pointArgs=dict(fillstyle='full'))
        pltt.plot_point(m2.r_arena_center,'','o',color=(0,0,0,0), markersize=2,ax=ax,pointArgs=dict(fillstyle='full'))
        pltt.plot_point(rect_p0,'(%g,%g)'%tuple(rect_p0),'o',color='tab:orange',      markersize=2,ax=ax,pointArgs=dict(fillstyle='full'))
        pltt.plot_point(rect_p1,'(%g,%g)'%tuple(rect_p1),'o',color='tab:orange',      markersize=2,ax=ax,pointArgs=dict(fillstyle='full'), pad=(-10,3))
        ax.set_title('%s'%(m1.exper_date))
        ax.set_aspect('equal')
        ax.set_position([ (1.0-ax_w)/2.0, (1.0-ax_h)/2.0, ax_w, ax_h ])
        ax.set_xlim([m1.arena_pic_left  , m1.arena_pic_right ])
        ax.set_ylim([m1.arena_pic_bottom, m1.arena_pic_top   ])
        ax.set_autoscale_on(False)
        ax.grid(visible=True,which='major',axis='both',alpha=0.2)
        plt.savefig('arena_picture/distort/arenas_experiments_16-Jul-2021.png',format='png',dpi=300,bbox_inches='tight')
        #ax[0].axis('off')
        fig,ax = plt.subplots(nrows=1,ncols=1,figsize=(fig_w,fig_h))
        pltt.draw_circle(m1.r_arena_center,m1.arena_diameter/2,ax=ax,linestyle='--',edgecolor=(0,0,0,0))
        pltt.draw_circle(m2.r_arena_center,m2.arena_diameter/2,ax=ax,linestyle=':' ,edgecolor='k')
        pltt.draw_rectangle(rect_p0, rect_L, rect_L,ax=ax,linestyle='-',edgecolor='r')
        pltt.plot_trajectory_points(  m1.r_arena_holes ,       ax=ax, marker='s', color=(0,0,0,0), linestyle='none', fillstyle='none',markersize=3)
        pltt.plot_trajectory_points(  m2.r_arena_holes ,       ax=ax, marker='d', color='b'      , linestyle='none', fillstyle='none',markersize=3)
        pltt.plot_point(m1.r_arena_center,'','o',color=(0,0,0,0),       markersize=2,ax=ax,pointArgs=dict(fillstyle='full'))
        pltt.plot_point(m2.r_arena_center,'','o',color='c'      ,       markersize=2,ax=ax,pointArgs=dict(fillstyle='full'))
        ax.set_title('%s'%(m2.exper_date))
        ax.set_aspect('equal')
        ax.set_position([ (1.0-ax_w)/2.0, (1.0-ax_h)/2.0, ax_w, ax_h ])
        ax.set_xlim([m1.arena_pic_left  , m1.arena_pic_right ])
        ax.set_ylim([m1.arena_pic_bottom, m1.arena_pic_top   ])
        ax.set_autoscale_on(False)
        ax.grid(visible=True,which='major',axis='both',alpha=0.2)
        plt.savefig('arena_picture/distort/arenas_experiments_15-Nov-2021.png',format='png',dpi=300,bbox_inches='tight')
        #ax[1].axis('off')

        plt.show()
    
    if TEST_ALIGN_TARGET_RANDOM_ENTRANCE:
        mouse_traj_dir_ft = r'./experiments/fixed_target/mouse_*'
        n_trials_to_use   = 14
        input_tracks      = io.load_trial_file(mouse_traj_dir_ft,load_only_training_sessions_relative_target=True,skip_15_relative_target=False,use_extra_trials_relative_target=True,sort_by_trial=True,fix_nan=True,remove_after_food=True,group_by='none',max_trial_number=n_trials_to_use)
        track_temp        = io.group_track_list(input_tracks,group_by='trial')[0]
        track_temp        = plib.align_targets_group_by_start_quadrant(track_temp, numpy.array((0,1)))
        for all_mice in track_temp:
            print(' --- ')
            print('trial %s'%all_mice[0].trial)
            for tr in all_mice:
                startquad  = plib.get_start_location_quadrant(tr.r_start)
                targetquad = plib.get_start_location_quadrant(tr.r_target)
                print('    * mouse = %s\t| startloc = %s\t| startquad = %d\t| targetquad = %d\t| r_start = %r\t\t\t| r_target = %r'%(tr.mouse_number,tr.start_location,startquad,targetquad,tr.r_start,tr.r_target))


    if TEST_HOLE_CHECK_DETECTION_HIGH_SPEED:
        mouse_traj_dir = r'./experiments/two_target_no_cues/mouse_*'
        time_delay_after_food = 3.0
        hole_horizon = 3.0
        all_trials_p2_complete = io.load_trial_file(mouse_traj_dir,file_name_expr='mpos_*Probe2_*',fix_nan=True,sort_by_trial=True,return_group_by_keys=False,remove_after_food=False)
        all_trials_p2          = tran.keep_path_between_targets(all_trials_p2_complete,return_t_in_targets=False,hole_horizon=10,time_delay_after_food=time_delay_after_food,copy_tracks=True)
        t0_trim = numpy.zeros(len(all_trials_p2),dtype=float)
        t0_trim[0]=15.0
        tracks_to_plot = [ tran.slice_track_by_time(tr,t0,t1=tr_trim.time[-1],copy_track=True) for tr,tr_trim,t0 in zip(all_trials_p2_complete,all_trials_p2,t0_trim) ]
        track  = tracks_to_plot[7]
        #k_slow,t_slow,r_slow,v_th = tran.find_slowing_down_close_to_hole(track,3,threshold_method='ampv',gamma=0.1,return_pos_from='hole',ignore_entrance_positions=False)
        k_slow,t_slow,r_slow,v_th = tran.find_slowing_down_close_to_hole(track,3,threshold_method='ampv',gamma=0.2,return_pos_from='hole',ignore_entrance_positions=False,use_velocity_minima=True,velocity_min_prominence=5.0)
        ax = pltt.plot_arena_sketch(track, arenaPicture=False, showHoles=True, showArenaCircle=True)
        pltt.plot_mouse_trajectory(ax,track,'nose',color='b')
        pltt.plot_trajectory_points(r_slow,ax=ax,marker='o',fillstyle='none',color='r',linestyle='none')

        fig,ax=plt.subplots(nrows=2,ncols=1,sharex=True,figsize=(8,4))
        ax[0].plot(track.time, track.velocity, '-b',label='Raw data')
        ax[0].plot(track.time,numpy.ones(track.time.size)*v_th,'--k')
        if k_slow.size>0:
            ax[0].plot(track.time[k_slow],numpy.ones(k_slow.size)*v_th,'or')
        ax[0].set_xlabel('Time (s)',fontsize=16)
        ax[0].set_ylabel('Velocity (cm/s)',fontsize=16)
        ax[0].set_title(track.get_info(),fontsize=16)
        ax[0].legend()

        a = numpy.diff(track.velocity)/numpy.diff(track.time)
        ax[1].plot(track.time[:-1],a, '-b',label='Raw data')
        ax[1].plot(track.time,numpy.zeros(track.time.size),'--k')
        if k_slow.size>0:
            ax[1].plot(track.time[k_slow],a[k_slow],'or')
        ax[1].set_xlabel('Time (s)',fontsize=16)
        ax[1].set_ylabel('Accel (cm/s$^2$)',fontsize=16)
        ax[1].legend()

        plt.show()


    if TEST_PROBE2_LATTICE_WALK:

        config_param           = dict(mouse_part           = ['nose']                           ,
                                      L                    = [11]                               ,
                                      prob_calc            = [misc.ProbabilityType.independent] ,
                                      start_from_zero      = [False]                            ,
                                      n_stages             = []                                 ,
                                      stop_at_food         = [True]                             ,
                                      use_latest_target    = [True]                             )


        filename_expr          = 'mpos_*Probe2_*'
        keep_between_targets   = True
        stop_at_food           = config_param['stop_at_food']
        hole_horizon           = 10.0 # cm
        time_delay_after_food  = 1.0 # sec
        mouse_traj_dir         = r'./experiments/two_target_no_cues/mouse_*'
        input_tracks           = io.load_trial_file(mouse_traj_dir,file_name_expr=filename_expr,align_to_top=True,fix_nan=True,sort_by_trial=True,return_group_by_keys=False,remove_after_food=False)
        if keep_between_targets:
            input_tracks       = tran.keep_path_between_targets(input_tracks,return_t_in_targets=False,hole_horizon=hole_horizon,time_delay_after_food=time_delay_after_food,copy_tracks=True)
        elif stop_at_food:
            input_tracks       = tran.remove_path_after_food(input_tracks,force_main_target=False,return_t_to_food=False,hole_horizon=hole_horizon,time_delay_after_food=time_delay_after_food,copy_tracks=True)
        use_extra_trials       = [True]
        align_method           = ['entrance'] # 'entrance' or 'target'

        n_trial_max              = numpy.unique([ plib.trial_to_number(tr.trial) for tr in input_tracks ]).size #n_trials_to_use if n_trials_to_use else max([ int(plib.trial_to_number(tr.trial)) for tr in input_tracks ])
        config_param['n_stages'] = [n_trial_max]
        config = tstep.get_step_prob_input_param_config_list(mouse_part        = config_param['mouse_part']       ,
                                                             n_stages          = config_param['n_stages']         ,
                                                             L_lattice         = config_param['L']                ,
                                                             prob_calc         = config_param['prob_calc']        ,
                                                             start_from_zero   = config_param['start_from_zero']  ,
                                                             use_extra_trials  = use_extra_trials                 ,
                                                             stop_at_food      = config_param['stop_at_food']     ,
                                                             align_method      = align_method                     ,
                                                             use_latest_target = config_param['use_latest_target'])
        
        param_struct   = tstep.get_calc_step_probability_param_struct(**config[0])
        step_prob_data = tstep.calc_step_probability(param_struct=param_struct,tracks=input_tracks,return_as_file_struct=True)
        
        fig,ax = plt.subplots(nrows=2,ncols=4,figsize=(16,8))
        
        for k,(track,P) in enumerate(zip(input_tracks,step_prob_data.P_specific[0])):
            G = numpy.zeros((param_struct.L_lattice,param_struct.L_lattice))
            G[numpy.unravel_index(numpy.unique(P.nonzero()[0]),shape=(param_struct.L_lattice,param_struct.L_lattice),order='F')] = 1
        
            aax = ax[numpy.unravel_index(k,ax.shape)]
            pltt.plot_arena_sketch(track,showAllEntrances=False,arenaPicture=False,showHoles=True,ax=aax)
            pltt.plot_arena_grid(aax,G,line_color=(0.8,0.8,0.8,0.5),show_grid_lines=True,grid_alpha=0.2)
            pltt.plot_mouse_trajectory(aax,track,mouse_part='nose',show_reverse_target=False,show_alt_target=True)
            aax.autoscale()
            aax.set_aspect('equal','box')
            aax.set_title('mouse %s'%track.mouse_number)
        
        pltt.tight_arena_panels(ax,set_axis_off=True,adjust_title_position=True,dy0=-0.2)
        
        plt.show()
    
    if TEST_FIND_HOLE_CHECK_PAPER:
        # calculating hole check for mouse 36 to use as example
        mouse_traj_dir = r'./experiments/two_target_no_cues/mouse_*'
        all_trials_p2_complete = io.load_trial_file(mouse_traj_dir,file_name_expr='mpos_*Probe2_*',fix_nan=True,sort_by_trial=True,return_group_by_keys=False,remove_after_food=False)
        tr = tran.slice_track_by_time(all_trials_p2_complete[3],t0=0.0,t1=45.0,copy_track=True)

        hole_horizon          = 10.0 # cm
        time_delay_after_food = 1.0 # sec
        start_vec_align       = (0,1)

        ignore_entrance_positions   = False
        normalize_by                = 'max'
        hole_horizon_hole_check     = 3.0 #cm
        threshold_method            = 'ampv'
        velocity_amplitude_fraction = 0.2
        use_velocity_minima         = True
        velocity_min_prominence     = 5.0 # cm/s
        k_slow,t_slow,r_slow,v_th   = tran.find_slowing_down_close_to_hole(tr,hole_horizon_hole_check,threshold_method=threshold_method,gamma=velocity_amplitude_fraction,
                                                                                                        return_pos_from='hole',ignore_entrance_positions=ignore_entrance_positions,
                                                                                                        use_velocity_minima=use_velocity_minima,velocity_min_prominence=velocity_min_prominence)
        use_velocity_minima           = False
        k_slow1,t_slow1,r_slow1,v_th1 = tran.find_slowing_down_close_to_hole(tr,hole_horizon_hole_check,threshold_method=threshold_method,gamma=velocity_amplitude_fraction,
                                                                                                        return_pos_from='hole',ignore_entrance_positions=ignore_entrance_positions,
                                                                                                        use_velocity_minima=use_velocity_minima,velocity_min_prominence=velocity_min_prominence)
        k_slow2,ind = misc.setdiff(k_slow,k_slow1)
        t_slow2     = t_slow[ind]
        r_slow2     = r_slow[ind]

        ax=pltt.plot_arena_sketch(tr,showHoles=True,showArenaCircle=True,showStart=True,
                                startArgs=dict(markersize=10,label='Start',labelArgs=dict(fontsize=16,va='top',ha='right',pad=(-2,-2))))
        pltt.plot_mouse_trajectory(ax,tr,show_start=False,show_target=True,show_alt_target=True,color=plt.get_cmap('cool'),line_gradient_variable='time',linewidth=3,alpha=1.0,targetArgs=dict(marker='o',fillstyle='none',color='b',markeredgewidth=3,markersize=10,label='B',labelArgs=dict(fontweight='bold',fontsize=20,va='bottom',ha='left',pad=(1,1),color='b')),targetAltArgs=dict(marker='o',fillstyle='none',color='r',markeredgewidth=3,markersize=10,label='A',labelArgs=dict(fontweight='bold',fontsize=20,va='top',ha='left',pad=(1,-1),color='r')),show_colorbar=True)

        t_seq = tr.time[k_slow]/tr.time[-1]
        pltt.plot_trajectory_points(r_slow,ax=ax,use_scatter=True,s=200,marker='*',c=plt.get_cmap('cool')(t_seq),zorder=10000,alpha=0.8)

        t_seq = tr.time[k_slow2]/tr.time[-1]
        pltt.plot_trajectory_points(r_slow2,ax=ax,use_scatter=True,s=200,marker='s',c=plt.get_cmap('cool')(t_seq),zorder=10000,alpha=0.8)

        pltt.tight_arena_panels(ax,set_axis_off=True)
        plt.show()

if __name__ == '__main__':
    run_tests()