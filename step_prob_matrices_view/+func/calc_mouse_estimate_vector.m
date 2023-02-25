function [v,v_unit,v_norm,v_norm_std,r0] = calc_mouse_estimate_vector(sites,simParam,nbootstrap_samples,rescale_to_target_distance,start_site,target_site)
% calculates the estimate of food position given by the sites step probability lattice struct
% the mouse estimate v is anchored at the reference r0 (i.e., r0 is the home position, or starting point)
%
% returns
%    v          -> mouse estimate (row vector in lattice coordinates, rescaled if requested)
%    v_unit     -> mouse estimate unit vector
%    v_norm     -> size of the mouse estimate (step units)
%    v_norm_std -> stddev of v_norm calculated using a bootstrap sample of all the step probabilities in sites
%    r0         -> start position as reference for v (row vector in lattice coordinates;
%                    if one is calculating between targets, this position is not valid, because this is the entrance position)
%
    if (nargin < 3) || isempty(nbootstrap_samples)
        nbootstrap_samples = 10;
    end
    if (nargin < 4) || isempty(rescale_to_target_distance)
        rescale_to_target_distance = true;
    end
    if (nargin < 5) || isempty(start_site)
        start_site = arena.get_start_position(simParam.start_pos,simParam.shape,simParam.L);
    end
    if (nargin < 6) || isempty(target_site)
        target_site = simParam.food_site;
    end
    
    L         = simParam.L(1);
    max_steps = 4.*(L.^2-L); % max number of steps in the lattice, hence max total displacement
    
    % start point (in lattice coordinates)
    r0      = func.myind2sub(simParam.L(1),start_site,true);
    
    % distance to the target (in lattice units)
    d_tgt   = arena.calc_lattice_site_distance(start_site,target_site,simParam.L);
    
    if rescale_to_target_distance
        % rescale_to_target_distance == true
        % or any number ~= 0
        rescale_factor = rescale_to_target_distance;
        if islogical(rescale_to_target_distance) || (rescale_to_target_distance == 1)
            rescale_factor = d_tgt;
        end
    else
        % rescale_to_target_distance == false
        % OR
        % rescale_to_target_distance == 0
        rescale_factor = max_steps./100;
    end

    
    calc_percent_displacement = @(step_vec) 100.*sum(step_vec,1)./max_steps; % step vec: grad. vector of step probabilities
    bootstrap_displacement    = @(nboot_samples,step_vec) bootstrp(nboot_samples,calc_percent_displacement,step_vec);
    calc_displacement_norm    = @(step_vec) vecnorm(step_vec,2,2);


    
    % calculating the gradient vector in each lattice site
    % this is the "step vector" since each gradient vector tells the max probability of stepping out of a lattice site
    G            = arena.calc_prob_gradient_with_positions(sites,simParam.L,true);
    
    % calculating the total displacement
    summed_steps = calc_percent_displacement(G);
    
    % calculating the 2-norm of displacement (i.e. euclidean intensity of the vector)
    v_norm  = calc_displacement_norm(summed_steps);
    
    % calculating the unit vector in the direction of the total displacement
    step_unit = summed_steps ./ v_norm;
    
    % the unit vector is the mouse estimate,
    % since we only care about the direction of the displacement
    v_unit = [step_unit(1),-step_unit(2)];
    
    % rescaling the estimate with the distance to the target
    % the estimate with some distance measurement that makes some sense
    v = v_unit .* rescale_factor;
    
    % bootstrap estimate of the norm of v
    v_norm_std = std(calc_displacement_norm(bootstrap_displacement(nbootstrap_samples,G))); % we take stddev over a bootstrap sample of the step vectors
end
