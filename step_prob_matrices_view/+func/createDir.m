function createDir(path)
    if exist(path,'dir') ~= 7
        [parent_dir,~] = fileparts(path);
        if exist(parent_dir,'dir') ~= 7
            func.createDir(parent_dir);
        end
        mkdir(path);
    end
end