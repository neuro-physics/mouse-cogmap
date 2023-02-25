function s = getRandomSample(n,N)
    s = sort(randperm(N,n),'ascend');
end