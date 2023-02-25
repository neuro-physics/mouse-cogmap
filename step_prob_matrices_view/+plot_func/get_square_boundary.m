function [xlim,ylim] = get_square_boundary(r0,dr)
% x0,y0 -> square center
% w,h   -> square width and height
    xlim = sort( [r0(1),r0(1)+dr(1)] );
    ylim = sort( [r0(2),r0(2)+dr(2)] );
end