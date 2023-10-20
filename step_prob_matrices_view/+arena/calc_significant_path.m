function [Gm,k] = calc_significant_path(sites_jk,stddev_level,avg_type,invert_y)
% returns only the gradient vectors that have stddev < stddev_level
% for each site of the lattice
%
% each row in the resulting Gm mean gradient vectors corresponds to the position
% [y,x] = ind2sub(simParam.L,(1:numel(prod(simParam.L)))'); % lattice position (m,n) for site i
%
% sites_jk     -> cell array containing a JackKnife sample of the arena sites from the mouse experiments (sites are calculated by the import.import_mouse_stepmat function
% stddev_level -> accepted angle deviation in radians from the mean vector displacement at the given site (e.g., pi/4)
% avg_type     -> type of average used to calculate the average gradient vector from the jackknife sample at each site... refer to func.angle_stddev
% invert_y     -> inverts sign of y component
%
% returns
% G -> [ [Gx,Gy]; [...]; ... ] average gradient at each site (1 2d vector per row)
% k -> significant gradient vectors (which rows of G are significant; i.e. have stddev less than stddev_level)
%

    if (nargin < 2) || isempty(stddev_level)
        stddev_level = pi/4;
    end
    if (nargin < 3) || isempty(avg_type)
        avg_type = '';
    end
    if (nargin < 4) || isempty(invert_y)
        invert_y = false;
    end
    
    avg_type_valid_values = {'mean','centroid','median'};
    assert(any(strcmpi(avg_type_valid_values,avg_type)),'avg_type must be one of: ''%s''',strjoin(avg_type_valid_values,''', '''));
    if strcmpi(avg_type,'mean')
        avg_f = @mean_vector;
    elseif strcmpi(avg_type,'centroid')
        avg_f = @centroid_vector;
    elseif strcmpi(avg_type,'median')
        avg_f = @median_vector;
    end

    assert(iscell(sites_jk),'sites_jk must be a cell-array of sites structure');

    G = cell(size(sites_jk));
    
    for k = 1:numel(sites_jk)
        [u,v] = arena.calc_prob_gradient(sites_jk{k});
        G{k}  = [u,v]; % gradient vector G(i,:) -> gradient at x(i),y(i)
    end
    
    G_s = func.stack_matrices(G);
    
    get_G_sample = @(GG,i) squeeze(GG(i,:,:))';

    % indices of the significant gradient vectors (within stddev_level of the average direction)
    k        =          arrayfun(@(i) func.angle_stddev(get_G_sample(G_s,i),avg_type) , 1:size(G_s,1)) < stddev_level;
    Gm       = cell2mat(arrayfun(@(i) avg_f(get_G_sample(G_s,i))                      , 1:size(G_s,1), 'UniformOutput', false)');
    Gm(~k,:) = 0;
    
    if invert_y
        Gm(:,2) = -Gm(:,2);
    end
end

function m = mean_vector(v)
% v is 1 vector per row
    m = mean(v,1,'omitnan');
end

function m = median_vector(v)
% v is 1 vector per row
    r     = mean(vecnorm(v,2,2));
    if r<1e-12 % all vectors are null
        m = [0,0];
    else
        theta = median(func.angle_between_vectors(v,[1,0]),'omitnan');
        m     = r.*[ cos(theta), sin(theta) ];
    end
end

function c = centroid_vector(v)
% v is 1 vector per row
    r = vecnorm(v,2,2);
    if all(r<1e-12) % all vectors are null
        c = [0,0];
    else
        R = sum(r,'omitnan');
        c = sum(repmat(r,1,2).*v,1,'omitnan')./R;
    end
end
