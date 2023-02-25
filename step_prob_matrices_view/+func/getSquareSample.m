function s = getSquareSample(n,N)
    L = view_activity.findCloseFactors(N);
    l = view_activity.findCloseFactors(n);
    [x,y] = meshgrid(1:L(1),1:L(2));
%     s = sub2ind(L,x(1:l(1),1:l(2)),y(1:l(1),1:l(2)));
    if any([l,l]>[L,L(end:-1:1)])
        error('there is no pair of integer factors for n that is less than the pair of factors for N')
    end
    s = reshape(sub2ind(L,x(1:l(1),1:l(2)),y(1:l(1),1:l(2))),1,[]);
end