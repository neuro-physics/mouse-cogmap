function l = rotate_start_label(start_pos_label,angle)
% CCW rotation -> angle > 0
% CW  rotation -> angle < 0
    R = func.rotation_mat(angle);
    if strcmpi(start_pos_label,'N')
        v = [0;1];
    elseif strcmpi(start_pos_label,'S')
        v = [0;-1];
    elseif strcmpi(start_pos_label,'W')
        v = [-1;0];
    elseif strcmpi(start_pos_label,'E')
        v = [1;0];
    else
        error('rotate_start_label::start_pos_label',sprintf('unknown start_pos_label: %s',start_pos_label));
    end
    u = int32(R*v);
    if all(u==[0;1])
        l = 'N';
    elseif all(u==[0;-1])
        l = 'S';
    elseif all(u==[-1;0])
        l = 'W';
    else %if all(u==[1;0])
        l = 'E';
    end
end