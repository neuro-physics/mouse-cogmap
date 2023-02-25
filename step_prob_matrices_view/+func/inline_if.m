function r = inline_if(cond,res_true,res_false)
    if cond
        r = res_true;
    else
        r = res_false;
    end
end