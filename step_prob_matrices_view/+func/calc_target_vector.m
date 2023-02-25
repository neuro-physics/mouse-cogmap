function v_t = calc_target_vector(simParam,tgt_site,start_site)
    if (nargin < 2) || isempty(tgt_site)
        tgt_site = simParam.food_site;
    end
    if (nargin < 3) || isempty(start_site)
        start_site = arena.get_start_position(simParam.start_pos,simParam.shape,simParam.L);
    end
    % start point (in lattice coordinates)
    r0      = func.myind2sub(simParam.L(1),start_site,true);
    % target point (in lattice coordinates)
    r_tgt   = func.myind2sub(simParam.L(1),tgt_site  ,true);
    v_t = r_tgt - r0;
end