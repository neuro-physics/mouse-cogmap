function M = fillUpMatrix(A, m, n, N)
% M is a matrix m X n
% composed of A (top left corner)
% if size(A) > size(M), then A is trimmed to fit M
% if number of cols of A is less than n, then the remaining n-size(A,2) cols of each line of A are
%       filled with randperm(N,n-size(A,2)) numbers not contained in the given line of A
% if number of rows of A is less than m, the matrix (with given corrections) is periodically
%       repeated, one below each other.
    [nr,nc] = size(A);
    mm = min(m,nr);
    nn = min(n,nc);
    M = zeros(m,n);
    for i = 1:mm
        r = getRandPerm(N, n - nn, A(i,1:nn)); % if n < size(A,2), then r = []
        M(i,:) = [ A(i,1:nn), r ];
    end
    if (m <= nr)
        return;
    end
    k = floor(m / nr);
    M(1:(k*nr),:) = repmat(M(1:nr,:), k, 1);
    M((k*nr+1):m,:) = M(1:(m-k*nr),:);
end

function r = getRandPerm(N, m, x)
    while true
        r = randperm(N, m);
        if isempty(intersect(r,sort(x)))
            return;
        end
    end
end
