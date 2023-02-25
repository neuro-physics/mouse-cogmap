function M = GetSurrogateRandomMatrix(A, mu, sigma, rescaleWeights)
% generates new weights based on the weight distribution of adjacency matrix A
% considering that A has Gaussian distributed weights
%
% 1) fits a Gaussian function to the distribution of weights P(A_ij) to estimate mean and std
% 2) generates numel(A~=0) Gaussian random numbers with the estimated mean and std;
%    if rescaleWeights == true, then the surrogate weights are contained within the boundaries minmax(A_ij)
% 3) replaces orderly the elements of A, from the smallest to the largest
%    i.e. the smallest element of A is replaced by the smallest random element, second smallest by the second random smallest, and so on
%
% based on algorithm by:
% Honey CJ, Sporns O, Cammoun L, Gigandet X, Thiran JP, Meuli R, Hagmann P.
% Predicting human resting-state functional connectivity from structural connectivity.
% Proc Natl Acad Sci USA. 2009 Feb 10;106(6):2035-40. doi: 10.1073/pnas.0811168106. Epub 2009 Feb 2.
%#codegen
    if nargin < 2 || isempty(mu)
        mu = 0;
    end
    if nargin < 3 || isempty(sigma)
        sigma = 10;
    end
    if nargin < 4 || isempty(rescaleWeights)
        rescaleWeights = false;
    end
    ind = find(A~=0);
    w = A(ind);
    wSub = sort(normrnd(mu, sigma, size(w)), 'ascend');
    [~,s] = sort(w, 'ascend');
    if rescaleWeights
        w(s) = linearTransf(wSub,[wSub(1),wSub(end)],[w(s(1)),w(s(end))]);
    else
        w(s) = wSub;
    end
    M = A;
    M(ind) = w;
end

% function err = findNBins(n,w)
%     [P,ww] = histcounts(w, n, 'Normalization', 'probability');
%     [ww,P] = prepareCurveData(ww(1:end-1),P);
%     pFit = fit(ww, P, 'gauss1');
%     wSub = normrnd(pFit.b1, pFit.c1 / sqrt(2), size(w));
%     Ps = histcounts(wSub, n, 'Normalization', 'probability');
%     err = norm(Ps-P);
% end

function y = linearTransf(x,xx,yy)
    a = (yy(2) - yy(1)) / (xx(2) - xx(1));
    b = yy(2) - a * xx(2);
    y = a .* x + b;
end
