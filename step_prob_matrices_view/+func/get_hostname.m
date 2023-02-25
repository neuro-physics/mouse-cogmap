function n = get_hostname()
    [~,n] = system('hostname');
    n = strtrim(n);
end
