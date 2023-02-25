function cond = get_simulation_output_files_to_remove_from_config(output_dir,config,get_output_filename_func)
    files_to_skip = dir(output_dir);
    is_dir = [ files_to_skip(:).isdir ];
    files_to_skip = {files_to_skip(:).name};
    files_to_skip(is_dir) = [];
    all_files = arrayfun(@(k)get_output_filename_func(config{k,:}),1:size(config,1),'UniformOutput',false);
    [~,ind] = intersect(all_files,files_to_skip,'stable');
    cond = false(1,size(config,1));
    cond(ind) = true;
end