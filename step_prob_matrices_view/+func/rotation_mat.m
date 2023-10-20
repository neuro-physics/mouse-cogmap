function R = rotation_mat(theta)
% returns the 2d rotation matrix about the origin of an angle theta (in radians)
% CCW rotation -> theta > 0
% CW  rotation -> theta < 0
    R = [ cos(theta), -sin(theta); sin(theta), cos(theta) ];
end