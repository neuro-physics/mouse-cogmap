function [mu,sigma] = FitMatrixWeights(A, nBins, showFit)
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
    if nargin < 2 || isempty(nBins)
        nBins = 100;
    end
    if nargin < 3 || isempty(showFit)
        showFit = false;
    end
    w = A(A~=0);
    [P,ww] = histcounts(w, nBins, 'Normalization', 'probability');
    [ww,P] = prepareCurveData(ww(1:end-1),P);
    pFit = fit(ww, P, 'gauss1');
    if showFit
        plot(pFit, ww, P);
    end
    mu = pFit.b1;
    sigma = pFit.c1 / sqrt(2);
end
