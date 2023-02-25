function [x,y] = get_square_vertices(x0,y0,w,h)
% x0,y0 -> square center
% w,h   -> square width and height
    x = [ (x0 - w/2).*ones(1,2), (x0 + w/2).*ones(1,2) ];
    y = [ (y0 - h/2),(y0 + h/2) ];
    y = [ y,fliplr(y) ];
end