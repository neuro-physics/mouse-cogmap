function B = repeat_edges(A)
    % given a matrix A m x n, it wraps it centralized and into a matrix with m+2 x n+2
    % thus repeating edge rows and cols
    [m,n]                  = size(A);
    B                      = zeros(m+2,n+2);
    B(2:(end-1),2:(end-1)) = A;
    B(1,2:(end-1))         = A(1,:);
    B(end,2:(end-1))       = A(end,:);
    B(2:(end-1),1)         = A(:,1);
    B(2:(end-1),end)       = A(:,end);
end