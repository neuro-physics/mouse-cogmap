function varargout = avg_angle_from_cos(cos_theta,in_deg,return_only_value)
    if (nargin < 2) || isempty(in_deg)
        in_deg = false;
    end
    if (nargin < 3) || isempty(return_only_value)
        return_only_value = 'all';
    end
    valid_return_values = {'avg','std','err','all','minmax'};
    assert(any(strcmpi(valid_return_values,return_only_value)),sprintf('return_only_value must be %s',strjoin(valid_return_values,', ')));
    
    to_deg = 1;
    if in_deg
        to_deg = 180/pi;
    end
    
    c_avg               = nanmean(cos_theta);
    c_avg(abs(c_avg)>1) = sign(c_avg(abs(c_avg)>1));
    c_std               = nanstd(cos_theta);
    theta_avg           = acos(c_avg).*to_deg;
    theta_std           = to_deg .* sqrt((1./abs(1-c_std.^2))) .* c_std; % propagated error from the cosine of angle theta = arccos(x); with d(arccos x)/dx = -1/sqrt(1-x**2)
    sqrt_of_n           = sqrt(sum(double(~isnan(cos_theta))));
    theta_err           = theta_std ./ sqrt_of_n;
    theta_minmax        = minmax(reshape(acos(cos_theta).*to_deg,1,[]));
    
    if strcmpi(return_only_value,'all')
        varargout = {theta_avg,theta_std,theta_err,theta_minmax};
    elseif strcmpi(return_only_value,'avg')
        varargout = {theta_avg};
    elseif strcmpi(return_only_value,'std')
        varargout = {theta_std};
    elseif strcmpi(return_only_value,'err')
        varargout = {theta_err};
    elseif strcmpi(return_only_value,'minmax')
        varargout = {theta_minmax};
    else
        error('avg_angle_from_cos:return_only_value','unknown return value');
    end
end