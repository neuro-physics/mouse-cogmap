function varargout = pvalue_stddev_of_uniform_angle_less_than_S(S,N,n_sample,n_bins,nbins_filter,use_rho_filtered_for_p,return_distribution)
% this function gives a numerical estimate of the probability p that the standard deviation s of N uniformly
% distributed variables (with zero mean) is less than or equal to S
% i.e., p = P(s<S) = integral of rho(s) from 0 to S
% where rho(s) is the Prob density function of s
%
% s is a random variable equal to
% s = sqrt( sum over k of ((theta_k-theta_mean)^2) / (N-1) )
% is the std dev of the N uniformly distributed variables theta_k
% theta_k is uniformly distributed from -pi to pi
%
% S            -> upper threshold for std dev of the N uniformly distributed variables (must be from 0 to pi)
% N            -> number of uniformly distributed variables
% n_sample     -> how many samples of the standard dev of the N uniform variables we will use
% n_bins       -> number of bins used for the histogram representing rho(s) (the prob density func of the std dev of the N uniform vars)
% nbins_filter -> number of bins used for filtering the histogram (lowpass convolution sliding average filter)
% return_distribution -> if true, the second return variable is the distribution of std dev used to estimate p
%
% returns
% p_values    -> p_values as a function of the variable s
% P           -> struct with fields P.P and P.s -> distribution rho(s) used to calculate the p-values
% P_filtered  -> convolution (sliding average) filtered P, with extra P.Pstd as the moving stddev of rho
%


    if (nargin < 3) || isempty(n_sample)
        n_sample = 100000;
    end
    if (nargin < 4) || isempty(n_bins)
        n_bins = 1000;
    end
    if (nargin < 5) || isempty(nbins_filter)
        nbins_filter = 30;
    end
    if (nargin < 6) || isempty(use_rho_filtered_for_p)
        use_rho_filtered_for_p = false;
    end
    if (nargin < 7) || isempty(return_distribution)
        return_distribution = false;
    end
    
    filterfunc     = @(y,n) conv(y,ones(1,n),'same');
    normalize_dist = @(f) f./sum(f);
    
    s = zeros(n_sample,1);
    for k = 1:n_sample
        s(k) = std((2.*rand(1,N)-1).*pi);
    end
    
    theta_edges  = linspace(-pi,pi,n_bins);
    rho          = histcounts(s,theta_edges,'Normalization','probability');
    rho_filtered = normalize_dist(filterfunc(rho,nbins_filter));
    
    s_values     = theta_edges(2:end);
    if use_rho_filtered_for_p
        p = arrayfun(@(S1) get_pvalue(rho_filtered,s_values,S1), S);
    else
        p = arrayfun(@(S1) get_pvalue(rho,s_values,S1), S);
    end
    
    varargout{1} = p;
    if return_distribution
        varargout{2} = struct('P',rho         ,'s',s_values);
        varargout{3} = struct('P',rho_filtered,'s',s_values,'Pstd',movstd(rho,nbins_filter));
    end
end

function p = get_pvalue(rho,s,S)
    [~,S_ind]   = min(abs(s-S));
    p           = sum( rho(1:S_ind) );
end