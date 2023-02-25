function s = calcMacroQuantities(a,N,tCorr)
% a -> activity struct vector (each element corresponding to an element in the vector of sizes N)
%         fields:
%           'A' : activity raw timeseries (number of spikes for each time step)
%           'A2': number of spikes squared for each time step
%           'A4': number of spikes to the 4th power
% N -> vector of sampling sizes (each element corresponds to the amount of neurons sampled in the activity sample)
% tCorr -> auto-correlation characteristic time used to sample A, A2 and A4 (assumed = 1 if not provided)
%
% returns
%    macroscopic quantities struct vector
%    'rho' -> order parameter (density of active sites)
%    'chi' -> susceptibility (variance of the density of active sites times N)
%    'U4'  -> Binder cumulant
    n = numel(N);
    s = repmat(struct('rho', [], 'chi', [], 'U4', []),size(a));
    for i = 1:n
        s(i) = measure_internal(s(i),a(i),N(i),getInd_internal(tCorr,numel(a(i).A)));
    end
end

function t = getInd_internal(tCorr,T)
    if tCorr == 1
        t = 1:T;
        return
    end
    n = floor(T/tCorr);
    TT = n * tCorr;
    t = zeros(numel(tCorr),n);
    for i = 1:tCorr
        t(i,:) = i:tCorr:TT;
    end
end

function s = measure_internal(s,a,N,ind)
    mA = calcMean(a.A,ind);
    mA2 = calcMean(a.A2,ind);
    mA4 = calcMean(a.A4,ind);
    s.rho =  mA / N;
    s.chi = (mA2 - mA*mA) / N;
    s.U4  = 1 - mA4 / ( 3 * mA2 * mA2 );
end

function m = calcMean(x,ind)
    n = size(ind,1);
    m = 0.0;
    for i = 1:n
        m = m + mean(x(ind(i,:)));
    end
    m = m / n;
end