function r = is_empty_dir(path)
    r = true;
    f = dir(path);
    for n = 1:numel(f)
        if (~strcmpi(f(n).name,'.')) && (~strcmpi(f(n).name,'..'))
            r = false;
            return
        end
    end
end