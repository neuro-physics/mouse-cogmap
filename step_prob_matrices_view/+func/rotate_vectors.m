function v = rotate_vectors(v, theta)
% rotate each row in v about the origin by an angle theta
% v -> a 2d row vector; or 1 2d vector per row

    for k = 1:size(v,1)
        v(k,:) = (func.rotation_mat(theta) * ( v(k,:)' ))';
    end
end