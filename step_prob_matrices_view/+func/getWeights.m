function weights = getWeights(type,p,sz)
% generates a matrix of size sz with weights of type distributed between p(1) and p(2)
    p = sort(p,'ascend');
    pMin = p(1);
    pMax = p(2);    
    if strcmpi(type,'gauss')
        weights = normrnd(0, 1, sz); % gaussian random with average 0 and stddev 1
    elseif strcmpi(type,'unif')
        weights = rand(sz);
    else
        error('unrecognized weight type');
    end
    wMin = min(weights(:));
    wMax = max(weights(:));
    a = (pMax - pMin) / (wMax - wMin);
    b = pMin - a * wMin;
    weights = b + weights .* a;
end