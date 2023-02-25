## Adding a new experiment to the mouse track program

Each experiment protocol usually comes in two batches: the first contains 4 mice; and the second contains 4 extra mice. These 8 mice must live in exactly the same reference frame. This is of utmost importance, otherwise the hole-checking statistics will be wrong.

The problem is that the second batch is almost always in a distorted reference of frame: camera angle changes, entrance changes, basically everything changes. We must work our way to realign both batches. Below, there will be steps where this (un)distortion protocol is explicitly mentioned.

### General procedure

Some of these steps are further detailed below

    1) Update functions in module process_mouse_trials_lib (see item A below)
    2) Prepare arena pictures for the script crop_arena_pictures.ipynb
    3) Check the needed distort transformation of coordinates using the photoshop guide file in arena_picture/distort
    4) Run crop_arena_pictures.ipynb
    5) Feedback into process_mouse_trials_lib the output from crop_arena_pictures.ipynb and update the remaining functions (see item A below)
    6) Include the excel experiment file directories into the script preprocess_mice_trials.py and run this script (debug eventual problems)
    7) Include the excel experiment file directories into the script calc_step_probability_matrix.py and run this script (debug eventual problems)

### A) Functions that will need to be updated:
    - in module process_mouse_trials_lib
        * get_arena_all_picture_filename
        * is_reverse_condition
        * get_arena_picture_bounds      (will be fed by the output of crop_arena_pictures.ipynb )
        * get_arena_center              (will be fed by the output of crop_arena_pictures.ipynb )
        * get_arena_entrance_coord      (will be fed by the output of crop_arena_pictures.ipynb;
                                         the coords need to be checked agains Kelly's convention of SW,NE,NW,SE
                                         the standard for me is the label-quadrant correspondence used in the pilot experiments;
                                         thus I have to make sure that the new experiment entrance labels 
                                         correspond to the quadrants of the same labels in the pilot experiments )
        * get_arena_hole_coord          (will be fed by the output of crop_arena_pictures.ipynb )
        * get_2target_target_index      (if it is a two target experiment, check which trial was used to switch targets;
                                         and check if this function needs updating)
        * get_2target_experiment_target (these targets are extracted from crop_arena_pictures.ipynb
                                         they need to checked agains new targets of 2-target experiments)
        * get_arena_alt_target          (returns the other target in 2-target experiments)
        * get_arena_target              (will be fed by Kelly's documentation or scripts)
        * get_arena_reverse_target      (will be fed by Kelly's documentation or scripts)
        * Create transform functions similar to the
                get_transform_for_15Nov2021_experiments_to_match_16Jul2021
                transform_15Nov2021_experiments_to_match_16Jul2021
          in order to (un)distort the 2nd batch of the same protocol onto the 1st batch coordinates  
        * These new transform functions must be added to
              ethovision_to_track_matfile
          with the proper modifications (experiment date checks -- copy from the 15Nov2021 or as needed)

### B) crop_arena_pictures.ipynb
    - See photoshop image of some already processed arena image file to use as guide, and
        * Create a _mark file with all the proper markings (green = entrance; red = target; blue = arena boundary; black = arena holes)
            see mark_scheme variable in first cell of this notebook
        * Create an _entrance file with black markers on the entrance (everything else must be white)
    - We will need to use these files and add a tuple to the list arena_pic in the first cell with the required modifications...
    - Run the crop_arena_pictures.ipynb and check the _holes.png output to see if the number of detected holes
      is correct... Usually the code finds more holes than the ones which are real, because it might find 2 or 3 times the same hole...
      When that is the case, correct the hole in photoshop by drawing a black circle on top of the hole (in the _mark) file
    - Check for the _holes.txt file for each of the processed pictures; it will be in the corresponding picture directory;
      these are the coordinates that must be placed in the corresponding functions in the process_mouse_trials_lib module
    - Once this is done, we can make the procedure to (un)distort the 2nd batch of mice of the same protocol to match the 1st batch
    
    Attention: pay attention to the documentation written there

    - extract the arena coordinates (entrance, holes, center, etc, using crop_arena_picture.ipynb)
    - (for the 2nd batch of the same experimental protocol) create a distort file following the template in photoshop, mark the distort points
    - (for the 2nd batch of the same experimental protocol) use engauge in the distort points to get the distorted square coordinates
    - (for the 2nd batch of the same experimental protocol) undistort the file (i.e., transform the 2nd batch to match the 1st batch)





