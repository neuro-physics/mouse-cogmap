function s = angle_stddev(v,avg_type,to_deg)
% v -> sample of 2d vectors (1 vector per row)
% 
% returns the stddev of the angles of each vector in v relative to the "average" of v
%
% the average of v can be one of the following:
%    - centroid = average of vectors in v weighted by each vector magnitude
%    - mean     = simple average of v=sum(v,1)./size(v,1)
%    - median   = median angle among all vectors in v
%
% returns the stddev of the angles of the input vectors v relative to the chosen average of v
%         in radians
    if (nargin < 2) || isempty(avg_type)
        avg_type = 'mean'; % 'mean' or 'centroid' or 'median'
    end
    if (nargin < 3) || isempty(to_deg)
        to_deg   = false;
    end
    
    avg_type_valid_values = {'mean','centroid','median'};
    assert(any(strcmpi(avg_type_valid_values,avg_type)),'avg_type must be one of: ''%s''',strjoin(avg_type_valid_values,''', '''));
    if strcmpi(avg_type,'mean')
        avg_f = @(X) mean(X,1,'omitnan');
    elseif strcmpi(avg_type,'centroid')
        avg_f = @centroid_vector;
    elseif strcmpi(avg_type,'median')
        avg_f = @median_vector;
    end
    
    % angle of each vector relative to [1,0]
    th               = func.angle_between_vectors(v,[1,0]);
    all_null_vectors = all(isnan(th));
    
    if all_null_vectors
        s = 0;
        return
    end
    
    % calculating the selected average
    vm  = avg_f(v);
    thm = func.angle_between_vectors(vm,[1,0]);
    
    if all(abs(vm)<1e-12) % in the case that the average vector is zero
        warning('angle_stddev:avg_type','null average vector... using average angle');
        thm = func.average_direction_angle(th);
    end
    
    % makes angle=0 == angle of the avg
    vr = func.rotate_vectors(v,-thm);
    % [0,pi] -> CCW angles; [-pi,0] -> CW angles
    s = std(func.angle_between_vectors(vr,[1,0]),'omitnan');
    
    if to_deg
        s = s * 180/pi;
    end
end

function m = median_vector(v)
% v is 1 vector per row
    theta = median(func.angle_between_vectors(v,[1,0]),'omitnan');
    m = [ cos(theta), sin(theta) ];
end

function c = centroid_vector(v)
% v is 1 vector per row
    r = vecnorm(v,2,2);
    R = sum(r,'omitnan');
    c = sum(repmat(r,1,2).*v,1,'omitnan')./R;
end
