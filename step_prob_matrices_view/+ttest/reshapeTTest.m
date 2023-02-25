function r = reshapeTTest(t, sz)
    sz = sz(:)';
    r = t;
    r.h = reshape(t.h,sz);
    r.hFDR = reshape(t.hFDR,sz);
    r.p = reshape(t.p,sz);
    r.t = reshape(t.t,sz);
    r.Cohen_Mahal = reshape(t.Cohen_Mahal,sz);
    r.effsz = reshapeLines(t.effsz,sz,'3darray');
    if ndims(r.effsz) == 3
        r.effsz = mean(r.effsz,3,'omitnan');
    end
    if size(t.confInt,1) >= 4
        r.confInt = reshape(t.confInt',[sz,2,2]);
    else
        r.confInt = reshape(t.confInt',[sz,2]);
    end
    r.stats.tstat = reshape(t.stats.tstat,sz);
    r.stats.df = reshape(t.stats.df,sz);
    if all(size(t.stats.df) == size(t.stats.sd))
        r.stats.sd = reshape(t.stats.sd,sz);
    else
        r.stats.sd = reshapeLines(t.stats.sd,sz,'3darray');
    end
end