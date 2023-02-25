function B = expandMatrix(A,sz)
% expands A such that in the end, size(A) == sz
% if any of the dimensions in sz is smaller than the initial size(A), that dimension will actually shrink
    if isscalar(sz)
        sz = [sz,sz];
    end
    B = zeros(sz);
    n = min(size(A),sz);
    B(1:n(1),1:n(2)) = A(1:n(1),1:n(2));
end