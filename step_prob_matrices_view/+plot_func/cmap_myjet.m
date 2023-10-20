function c = cmap_myjet(N)
    if nargin < 1
        f = get(groot,'CurrentFigure');
        if isempty(f)
            N = size(get(groot,'DefaultFigureColormap'),1);
        else
            N = size(f.Colormap,1);
        end
    end
    all_jet = jet(100);
    k1      = 13;
    k2      = 88;
    if N <= (k2-k1)
        c = all_jet(round(linspace(k1,k2,N)),:);
    else
        c = interp1(k1:k2,all_jet(k1:k2,:),linspace(k1,k2,N));
    end
end