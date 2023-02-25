function varargout = angle_between_vectors(v1,v2,in_deg,return_only_cos_theta)
% v1 is a row vector or a collection of 1 vector per row
% v2 is a row vector or a collection of 1 vector per row
% return
%   theta: angle between v1 and v2 (or each row of v1 and the corresponding row of v2)
%      CCW angles relative to v2 are positive [0,pi] ; CW angles are negative [-pi,0]
    if (nargin < 3) || isempty(in_deg)
        in_deg = false;
    end
    if (nargin < 4) || isempty(return_only_cos_theta)
        return_only_cos_theta = false;
    end
    
    to_deg = 1;
    if in_deg
        to_deg = 180/pi;
    end
    n = max(size(v1,1),size(v2,1));

    if size(v1,1) ~= n
        v1 = repmat(v1,n,1);
    end
    if size(v2,1) ~= n
        v2 = repmat(v2,n,1);
    end
    
    cos_theta                   = dot(v1,v2,2)./(vecnorm(v1,2,2).*vecnorm(v2,2,2));
    cos_theta(abs(cos_theta)>1) = sign(cos_theta(abs(cos_theta)>1));
    theta                       = is_to_the_right(v1,v2).*acos(cos_theta).*to_deg;
    
    if return_only_cos_theta
        varargout = {cos_theta};
    else
        varargout = {theta,cos_theta};
    end
end

function s = is_to_the_right(u,v)
% s is 1 if u is to the right of v; -1 otherwise
% assuming u and v are of same size
% each row vector in u corresponds to a row vector in v
    R = rot_matrix_CCW(pi/2);
    s = ones(size(u,1),1);
    for i = 1:size(u,1)
        s(i) = 2*int32(dot( u(i,:), R*(v(i,:)') ) > 0.0)-1;
    end
end

function R = rot_matrix_CCW(theta)
    R = [ cos(theta), -sin(theta); sin(theta), cos(theta)  ];
end