## Adding a new experiment to the mouse track program

Each experiment protocol usually comes in two batches: the first contains 4 mice; and the second contains 4 extra mice. These 8 mice must live in exactly the same reference frame. This is of utmost importance, otherwise the hole-checking statistics will be wrong.

The problem is that the second batch is almost always in a distorted reference frame: camera angle changes, entrance changes, basically everything changes. We must work our way to realign both batches. Below, there will be steps where this (un)distortion protocol is explicitly mentioned.

### General procedure

Some of these steps are further detailed below

     0) search for the following parameters: target (first, second, reverse) positions, arena picture extent, and use the notebook `preliminary_plot_arena.ipynb` to show a preliminary picture of the arena with targets, center (center is usually mean of all target positions) and circle/square marked
     1) mark the original arena picture according to the photoshop template (see e.g. the PSD files in `arena_picture/2022`) using the marked features from previous step; save this as a `_mark.png` arena picture
     2) use this mark file to crop arena pictures in `crop_arena_pictures.ipynb` and get a preliminary (not aligned) arena picture, and all the holes positions
     3) Update functions in module `process_mouse_trials_lib.py` according to the preliminary parameters from previous step
     4) Process a few trials (in `preprocess_mice_trials.py`) and use them to create the undistort transform in `plot_refsquare_undistort_exper.ipynb`
     5) Use the arena parameters in photoshop using the template file in `arena_picture/distort`
     6) Prepare arena pictures for the script `crop_arena_pictures.ipynb` (see item B below)
     7) Run `crop_arena_pictures.ipynb`
     8) Feedback into `process_mouse_trials_lib` the output from `crop_arena_pictures.ipynb` and update the remaining functions (see item A below)
     9) Include the excel experiment file directories into the script `preprocess_mice_trials.py` and run this script (debug eventual problems)
    10) Include the excel experiment file directories into the script `calc_step_probability_matrix.py` and run this script (debug eventual problems)

### A) Functions that will need to be updated:
    - in module process_mouse_trials_lib
        * `get_arena_all_picture_filename`
        * `is_reverse_condition`
        * `get_arena_picture_bounds`      (will be fed by the output of crop_arena_pictures.ipynb )
        * `get_arena_center`              (will be fed by the output of crop_arena_pictures.ipynb )
        * `get_arena_entrance_coord`      (will be fed by the output of crop_arena_pictures.ipynb;
                                          use the targets plotted in `preliminary_plot_arena.ipynb` to define the entrance labels:
                                          the label is usually "opposite" to the target labels (depending on experimental condition/task)
                                          the coords need to be checked against Kelly's convention of SW,NE,NW,SE
                                          the standard for me is the label-quadrant correspondence used in the pilot experiments;
                                          thus I have to make sure that the new experiment entrance labels 
                                          correspond to the quadrants of the same labels in the pilot experiments )
        * `get_arena_hole_coord`          (will be fed by the output of crop_arena_pictures.ipynb )
        * `get_2target_target_index`      (if it is a two target experiment, check which trial was used to switch targets;
                                          and check if this function needs updating)
        * `get_2target_experiment_target` (these targets are extracted from crop_arena_pictures.ipynb
                                          they need to checked agains new targets of 2-target experiments)
        * `get_arena_alt_target`          (returns the other target in 2-target experiments)
        * `get_arena_target`              (will be fed by Kelly's documentation or scripts)
        * `get_arena_reverse_target`      (will be fed by Kelly's documentation or scripts)
        * Create transform functions similar to the
                `get_transform_for_15Nov2021_experiments_to_match_16Jul2021`
                `transform_15Nov2021_experiments_to_match_16Jul2021`
          in order to (un)distort the 2nd batch of the same protocol onto the 1st batch coordinates  
        * These new transform functions must be added to
              `ethovision_to_track_matfile`
          with the proper modifications (experiment date checks -- copy from the `15Nov2021` or as needed)

### B) crop_arena_pictures.ipynb
    - See photoshop image of some already processed arena image file to use as guide, and
        * Create a _mark file with all the proper markings (`green = entrance`; `red = target`; `blue = arena boundary`; `black = arena holes`)
            see `mark_scheme` variable in first cell of this notebook
        * (deprecated; `_mark` file is enough) Create an `_entrance` file with black markers on the entrance (everything else must be white)
    - We will need to use these files and add a tuple to the list `arena_pic` in the first cell with the required modifications...
    - Run the `crop_arena_pictures.ipynb` and check the `_holes.png` output to see if the number of detected holes
      is correct (100 holes)... Usually the code finds more holes than the ones which are real, because it might find 2 or 3 times the same hole...
      When that is the case, correct the hole in photoshop by drawing a black circle on top of the hole (in the `_mark`) file
    - Check for the `_holes.txt` file for each of the processed pictures; it will be in the corresponding picture directory;
      these are the coordinates that must be placed in the corresponding functions in the `process_mouse_trials_lib` module
    - Once this is done, we can make the procedure to (un)distort the 2nd batch of mice of the same protocol to match the 1st batch
    
    Attention: pay attention to the documentation written there

    - extract the arena coordinates (entrance, holes, center, etc, using `crop_arena_picture.ipynb`)
    - (for the 2nd batch of the same experimental protocol) create a distort file following the template in photoshop, mark the distort points
    - (for the 2nd batch of the same experimental protocol) use engauge in the distort points to get the distorted square coordinates
    - (for the 2nd batch of the same experimental protocol) undistort the file (i.e., transform the 2nd batch to match the 1st batch)





