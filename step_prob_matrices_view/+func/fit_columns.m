function f = fit_columns(X,Y,varargin)
% fits each column of Y vs. each corresponding column in X
    if isvector(X)
        X = X(:);
    end
    if isvector(Y)
        Y = Y(:);
    end
    n=size(Y,2);
    assert(size(X,2)==n,'X must be a matrix the same shape as Y');
    f = cell(1,n);
    for i = 1:n
        x = X(:,i);
        y = Y(:,i);
        f{i} = fit(x,y,varargin{:});
    end
end