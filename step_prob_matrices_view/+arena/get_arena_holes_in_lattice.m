function r_latt = get_arena_holes_in_lattice(L,rotation_angle)
    if (nargin < 2) || isempty(rotation_angle)
        rotation_angle = 0;
    end
    r = [-48.2102,-6.85804;-47.5773,5.02923;-43.983,-21.1837;-42.6746,23.0125;-40.9232,-12.0397;-39.446,-32.7662;...
        -38.4601,2.59081;-38.3998,31.547;-36.9156,14.1733;-35.1699,-23.6221;-33.002,-4.72443;-32.7595,-34.2902;-31.1985,-14.7829;...
        -29.8921,28.499;-28.7024,15.6973;-27.5128,2.89562;-26.6647,-27.8894;-26.4025,-48.0063;-24.7031,37.9478;-23.344,-39.4718;...
        -23.1688,44.6534;-22.9916,-16.3069;-21.7538,-5.94363;-18.6343,31.8518;-17.8979,-52.5783;-16.8409,16.9165;-15.3993,-20.8789;...
        -15.3422,6.55324;-14.3588,40.691;-11.9078,49.5303;-11.7605,-25.7557;-11.6634,20.8789;-10.5703,-38.2526;-10.1862,0.152401;...
        -9.06703,-46.4823;-8.99022,-9.60125;-7.08705,28.1942;-5.5489,36.7286;-2.79191,46.4823;-1.41944,-24.5365;-0.460239,-1.98121;...
        -0.425959,14.4781;0.0323754,-57.4551;2.08917,54.1023;2.50814,-36.7286;2.78873,-48.0063;3.24897,26.9749;4.48939,38.5574;...
        5.28101,-19.3549;7.12641,-9.29645;7.15751,5.63883;9.30635,15.3925;9.79389,-42.5198;11.3384,-30.9374;11.7986,44.0438;...
        12.0792,32.7662;12.1941,-58.0647;14.2509,53.4927;14.7435,-1.98121;15.0133,-18.4405;15.7027,20.5741;17.3786,-50.7495;...
        20.1363,-40.691;21.6744,-32.1566;23.3509,42.8246;23.5782,5.94363;24.4701,-3.81002;25.1583,34.595;26.0445,22.0981;...
        26.2508,-24.8413;26.7986,-53.7975;28.9456,-44.9582;29.6254,-10.5157;29.9873,17.2213;31.4283,-20.8789;32.4859,48.9207;...
        33.5251,-36.119;36.0377,2.28601;37.2756,12.6493;37.932,35.8142;38.363,-49.2255;39.898,-42.215;40.9911,44.6534;...
        41.2533,24.5365;42.1008,-6.55324;43.5932,-19.9645;44.7829,-32.7662;46.0906,11.1253;47.3475,30.6326;47.59,1.06681;...
        50.062,19.9645;52.1111,-18.1357;53.3522,-6.24843;53.8981,-36.119;54.3381,29.1086;55.8153,8.38205;58.1736,-27.2797;...
        58.8757,17.8309;63.0769,-8.99165;63.407,3.50522];
    %  rm = [7.59409,-1.9734]
    rm            = [7.59409,-1.9734]; %mean(r,1);
    r             = r - repmat(rm,size(r,1),1); % displacing the true center to [x,y] = [0,0]
    transf        = @(s) linearTransform(s,[-62,62],[0,L-0.00001]); % these limits are copied from python functions: tstep.get_arena_to_lattice_transform and plib.get_arena_grid_limits
    r_latt        = [transf(r(:,1)),transf(-r(:,2))] + repmat(0.5.*ones(1,2),size(r,1),1);
    r_latt_center = mean(r_latt,1);%((L+1)/2).*ones(1,2);
    r_latt        = rotate_vectors(r_latt,rotation_angle,r_latt_center);
end

function Y = linearTransform(X,X_range,Y_range)
    if (nargin < 2) || isempty(X_range)
        X_range = minmax(X(:)');
    end
    if isempty(Y_range)
        error('linearTransform:Y_range','Y_range cannot be emtpy');
    end
    if isempty(X)
        error('linearTransform:X','X cannot be emtpy');
    end
    if numel(X_range)~=2
        error('linearTransform:X_range','X_range must have 2 elements');
    end
    if numel(Y_range)~=2
        error('linearTransform:Y_range','Y_range must have 2 elements');
    end
    dY = diff(Y_range);
    dX = diff(X_range);
    if dX ~= 0
        % Y = A.*X + B
        A = dY ./ dX;
        B = Y_range(1) - A.*X_range(1);
        Y = A.*X + B;
    else
        warning('linearTransform:X_range','singular X_range, so Y = X');
        Y = X;
    end
end

function v = rotate_vectors(v, theta, v_center)
% rotate each row in v about the origin by an angle theta
% v -> a 2d row vector; or 1 2d vector per row
    if (nargin < 3) || isempty(v_center)
        v_center = [0,0];
    end
    %M = rotation_mat(theta,v_center);
    cos_th = cos(theta);
    sin_th = sin(theta);
    v = [ (cos_th.*(v(:,1) - v_center(1)) + v_center(1) - sin_th .* (v(:,2) - v_center(2))),...
          (sin_th.*(v(:,1) - v_center(1)) + v_center(2) + cos_th .* (v(:,2) - v_center(2))) ];
    
    %for k = 1:size(v,1)
    %    vs     = [v(k,:),0]';
    %    vr     = (M * ( vs ))';
    %    v(k,:) = vr(1:2);
    %end
end

function M = rotation_mat(theta,v_center)
% returns the 2d rotation matrix about the origin of an angle theta (in radians)
% CCW rotation -> theta > 0
% CW  rotation -> theta < 0
    D = [ 1,0,v_center(1);...
          0,1,v_center(2);...
          0,0,1 ];
    R = [ cos(theta), -sin(theta), 0;...
          sin(theta), cos(theta) , 0;...
          0,0,1];
    Dp= [ 1,0,-v_center(1);...
          0,1,-v_center(2);...
          0,0,1 ];
    M = D*(R*Dp);
end