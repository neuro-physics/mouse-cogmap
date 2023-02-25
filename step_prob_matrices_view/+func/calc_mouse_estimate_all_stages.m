function r = calc_mouse_estimate_all_stages(all_learning_stages,simParam,nbootstrap_samples,rescale_to_target_distance,start_site,target_site)

    if (nargin < 3) || isempty(nbootstrap_samples)
        nbootstrap_samples = 10;
    end
    if (nargin < 4) || isempty(rescale_to_target_distance)
        rescale_to_target_distance = true;
    end
    if (nargin < 5) || isempty(start_site)
        start_site = [];
    end
    if (nargin < 6) || isempty(target_site)
        target_site = [];
    end
    if isscalar(rescale_to_target_distance)
        rescale_to_target_distance = rescale_to_target_distance.*ones(size(all_learning_stages));
    end
    
    output_struct = struct('mouse_id',[],'v',[],'v_unit',[],'v_norm',[],'v_norm_std',[],'r0',[]);
    r = repmat(output_struct,size(all_learning_stages));

    for k = 1:numel(all_learning_stages)
        n_mice          = numel(all_learning_stages(k).mouse);
        r(k).mouse_id   = zeros(n_mice,1); % one mouse per row
        r(k).v          = zeros(n_mice,2); % one mouse estimate vector per row
        r(k).v_unit     = zeros(n_mice,2); % one mouse estimate vector per row
        r(k).v_norm     = zeros(n_mice,1); % one mouse estimate per row
        r(k).v_norm_std = zeros(n_mice,1); % one mouse estimate per row
        r(k).r0         = zeros(n_mice,2); % one mouse start position vector per row
        for i = 1:numel(all_learning_stages(k).mouse)
            if isempty(all_learning_stages(k).mouse(i).t_food)
                r(k).mouse_id(i)   = NaN;
                r(k).v(i,:)        = NaN(1,2);
                r(k).v_unit(i,:)   = NaN(1,2);
                r(k).v_norm(i)     = NaN;
                r(k).v_norm_std(i) = NaN;
                r(k).r0(i,:)       = NaN(1,2);
            else
                sites                           = all_learning_stages(k).mouse(i).sites;
                [v,v_unit,v_norm,v_norm_std,r0] = func.calc_mouse_estimate_vector(sites,simParam,nbootstrap_samples,rescale_to_target_distance(k),start_site,target_site);
                r(k).mouse_id(i)   = all_learning_stages(k).mouse(i).mouse_id; % one mouse per row
                r(k).v(i,:)        = v; % one mouse estimate vector per row
                r(k).v_unit(i,:)   = v_unit; % one mouse estimate vector per row
                r(k).v_norm(i)     = v_norm; % one mouse estimate per row
                r(k).v_norm_std(i) = v_norm_std; % one mouse estimate per row
                r(k).r0(i,:)       = r0; % one mouse start position vector per row
            end
        end
    end
end