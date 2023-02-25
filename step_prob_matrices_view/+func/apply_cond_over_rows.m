function cond = apply_cond_over_rows(C,cond_func)
    % C is a NxM cell array
    % cond_func is a function that receives M arguments (one for each col in C)
    % i.e., cond_func = cond_func( C{k,:} )
    %
    % this function then applies cond_func to each row k of C
    % and returns the result as an array
    %
    % cond_func must return bool
    %
    cond = arrayfun(@(k)cond_func(C{k,:}),1:size(C,1));
end