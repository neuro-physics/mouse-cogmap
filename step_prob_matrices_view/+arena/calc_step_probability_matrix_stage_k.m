function pk = calc_step_probability_matrix_stage_k(nk)
% calculates the learning stage k probability pk based on the number of steps in stage k, nk
% this function should have the same functionality as the one with the same name in
% D:\Dropbox\p\uottawa\data\animal_trajectories\mouse_track\process_mouse_trials_lib.py
    pk = arena.normalize_cols(nk./sum(nk(:)));
end