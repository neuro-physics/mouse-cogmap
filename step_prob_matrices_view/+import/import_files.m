function d = import_files(filename_ptrn)
    f = dir(filename_ptrn);
    if numel(f) == 1
        d = [];
        if ~f.isdir
            d = load(fullfile(f.folder,f.name));
        end
    else
        d={};
        for k = 1:numel(f)
            if ~f(k).isdir
                d{end+1} = load(fullfile(f(k).folder,f(k).name));
            end
        end
    end
end