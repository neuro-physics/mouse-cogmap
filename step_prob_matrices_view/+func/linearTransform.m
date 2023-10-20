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