function [x,y] = sorw_get_lattice_square_for_linear_index(s,L)
    [y,x] = ind2sub(L,s);
    x = [x-0.5,x+0.5,x+0.5,x-0.5];
    y = [y-0.5,y-0.5,y+0.5,y+0.5];
end