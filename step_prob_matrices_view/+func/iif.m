function r = iif(cond,result_is_true,result_is_false)
    if cond
        r = result_is_true;
    else
        r = result_is_false;
    end
end