function s = get_sites_for_learning_stage(mouse_stepmat_import_data,stage_or_trial)
    if iscell(mouse_stepmat_import_data)
        s = cellfun(@(d) import.get_sites_for_learning_stage(d,stage_or_trial), mouse_stepmat_import_data, 'UniformOutput',false);
    else
        s = mouse_stepmat_import_data.sites_per_stage{stage_or_trial};
    end
end