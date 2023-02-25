function [h,p,ci,stats,t,slm] = tTestSurfStat(x,y,varargin)
% x,y -> two input vectors or matrices or tensors with the following structure (corresoponding to different groups: G.X and G.Y)
%        lines   -> observations (or each subject value)
%        columns -> different quantities to compare x(:,c) vs. y(:,c)
%        3rd dim -> different variables for each column (so that a multivariate test is performed)
% params -> 'Alpha' (alpha threshold for the p values)
%           'AlphaFDR' (alpha threshold for the FDR correction if x and y are matrices or tensors)
%           'Model'      -> a SurfStatLinMod model definition (use G for group term and C1, C2, ..., Cn for all the covariate terms); DEFAULT: 1 + G
%           'TestDomain' -> the SurfStatT 'contrast' (which determines the x-axis of the model linear fit, I suppose) -- use same notation as Model; G.X - G.Y
%           'Cn_x'       -> n may be 1, 2, ...; covariate data for x variable to be taken into account in the Model
%           'Cn_y'       -> n may be 1, 2, ...; covariate data for y variable to be taken into account in the Model
%           'N_cols_max' -> does the t-test separately splitting x and y into matrix with a maximum of N_cols_max columns
    %r = struct('h',[],'p',[],'t',[],'hFDR',[],'pFDR',[],'confInt',[],'stats',[],'alpha',[],'alphaFDR',[]);
    params = varargin;
    if (nargin < 3) || isempty(params)
        params = {};
    end

    if isvector(x)
        x = x(:);
    end
    if isvector(y)
        y = y(:);
    end
    if isValidMatrix(x) && isValidMatrix(y)
        if ~((size(x,2) == size(y,2)) && (size(x,3) == size(y,3)))
            error('size(x,2) and size(x,3) must match corresponding sizes of y')
        end
    else
        error('if x is matrix, y must be matrix')
    end
    
    [n_col_max,params] = getParamValue('N_cols_max',params,true,size(x,2));
    
    [modelDef,params] = getParamValue('Model',params,true,'');
    if isempty(modelDef)
        isModelDefined = false;
        modelDef = '1+G';
    else
        isModelDefined = true;
    end
    testDomainDef = getParamValue('TestDomain',params,true,'G.X-G.Y');
    [coRaw,co] = getAllCovariates(params);
    if ~isempty(co)
        [modelDef,testDomainDef] = correctModelDefCov(modelDef,testDomainDef,co);
    end
    
    isNanX = isnan(x);
    isNanY = isnan(y);
    dim = numel(size(x));
    if any(isNanX(:)) || any(isNanY(:))
        if isModelDefined
            slm = ttestSS(x,y,n_col_max,modelDef,testDomainDef,co,coRaw);
            %error('tTestSurfStat:foundNaN','A model is externally defined and there is NaN in the data');
        else
            try
                % tests column stack of x vs. column stack of y separately
                N = size(x,2);
                slm = getEmptySLM();
                e = [];
                for i = 1:N
                    x0 = selNumRows(x(:,i,:),~isNanX(:,i,:));
                    y0 = selNumRows(y(:,i,:),~isNanY(:,i,:));
                    if numel(size(x0)) ~= numel(size(y0))
                        x0 = reshape(x0,numel(x0),1);
                        y0 = reshape(y0,numel(y0),1);
                    end
                    try
                        slm0 = ttestSS(x0,y0,size(x0,2),modelDef,testDomainDef,co,coRaw);
                    catch e
                        slm0 = getEmptySLM(numel(size(x)));
                    end
                    slm = concatSLM(slm,slm0,dim);
                end
                slm.X = slm0.X;
                slm.c = slm0.c;
                slm.k = slm0.k;
                if ~isempty(e)
                    slm.error = e;
                end
            catch
                slm = ttestSS(x,y,n_col_max,modelDef,testDomainDef,co,coRaw);
            end
        end
    else
        slm = ttestSS(x,y,n_col_max,modelDef,testDomainDef,co,coRaw);
    end
    
    alpha = getParamValue('Alpha',params,true,0.05);
    tail = getTailValue(getParamValue('Tail',params,true,'Both'));

    dim = 1;
    t = slm.t;
    % copied from ttest2 from Statistics toolbox MATLAB
    % Compute the correct p-value for the test, and confidence intervals
    if tail == 0 % two-tailed test
        p = 2 * tcdf(-abs(slm.t),slm.df);
        spread = bsxfun(@times,tinv(1 - alpha ./ 2, slm.df), slm.sd);%spread = tinv(1 - alpha ./ 2, slm.df) .* slm.sd;
        ci = cat(dim, slm.ef-spread, slm.ef+spread);
    elseif tail == 1 % right one-tailed test
        p = tcdf(-slm.t,slm.df);
        spread = bsxfun(@times,tinv(1 - alpha, slm.df), slm.sd);%spread = tinv(1 - alpha, slm.df) .* slm.sd;
        ci = cat(dim, slm.ef-spread, Inf(size(p)));
    elseif tail == -1 % left one-tailed test
        p = tcdf(slm.t,slm.df);
        spread = bsxfun(@times,tinv(1 - alpha, slm.df), slm.sd);%spread = tinv(1 - alpha, slm.df) .* slm.sd;
        ci = cat(dim, -Inf(size(p)), slm.ef+spread);
    end
    % Determine if the actual significance exceeds the desired significance
    h = cast(p <= alpha, 'like', p);
    h(isnan(p)) = NaN; % p==NaN => neither <= alpha nor > alpha
    stats = struct('tstat',slm.t,'df',slm.df.*ones(size(slm.t)),'sd',slm.sd);
end

function slm = mergeSLM(slm1,slm2,kk)
% kk is logical index such that numel(kk) == numel(slm1.t) + numel(slm2.t)
% values from slm1 will be inserted into find(kk) and from slm2 into find(~kk)
    slm = getEmptySLM(numel(size(slm1.coef)),numel(kk));
    s1 = max(size(slm1.coef,1),size(slm2.coef,1));
    s2 = max(size(slm1.coef,3),size(slm2.coef,3));
    slm.coef = completeToSize_internal(NaN,[s1,numel(kk),s2]);
    slm.X = slm1.X;
    slm.c = slm1.c;
    slm.k = slm1.k;
    slm.df(:,kk) = slm1.df;           slm.df(:,~kk) = slm2.df;
    slm.t(:,kk) = slm1.t;              slm.t(:,~kk) = slm2.t;
    slm.coef(:,kk,:) = slm1.coef; slm.coef(:,~kk,:) = completeToSize_internal(slm2.coef,[s1,numel(slm2.t),s2]);
    slm.SSE(:,kk) = slm1.SSE;        slm.SSE(:,~kk) = slm2.SSE;
    slm.ef(:,kk) = slm1.ef;           slm.ef(:,~kk) = slm2.ef;
    slm.sd(:,kk) = slm1.sd;           slm.sd(:,~kk) = slm2.sd;
end

function slm = concatSLM(slm,slm0,dim,concatCoef)
    if (nargin < 4) || isempty(concatCoef)
        concatCoef = true;
    end
    if dim == 3
        s1 = max(size(slm.coef,1),size(slm0.coef,1));
        s2 = numel(slm.t);
        if concatCoef
            slm.coef = cat(2,completeToSize_internal(slm.coef,[s1,s2,2]),completeToSize_internal(slm0.coef,[s1,1,2]));
        end
        slm.SSE = cat(2,completeToSize_internal(slm.SSE,[s1,s2]),completeToSize_internal(slm0.SSE,[s1,1]));
        slm.ef = cat(2,completeToSize_internal(slm.ef,[2,s2]),completeToSize_internal(slm0.ef,[2,1]));
        slm.sd = cat(2,completeToSize_internal(slm.sd,[2,s2]),completeToSize_internal(slm0.sd,[2,1]));
    else
        if concatCoef
            slm.coef = cat(2,slm.coef,slm0.coef);
        end
        slm.SSE = cat(2,slm.SSE,slm0.SSE);
        slm.ef = cat(2,slm.ef,slm0.ef);
        slm.sd = cat(2,slm.sd,slm0.sd);
    end
    slm.df = cat(2,slm.df,slm0.df);
    slm.t = cat(2,slm.t,slm0.t);
end

function slm = getEmptySLM(dim,n)
    if (nargin < 2)
        n = 1;
    end
    slm = struct('X',[],'df',[],'coef',[],'SSE',[],'c',[],'k',[],'ef',[],'sd',[],'t',[]);
    if (nargin >= 1)
        slm.df = NaN(1,n);
        slm.t = NaN(1,n);
        if dim == 3
            slm.coef = NaN(3,n,2); % number of lines in this vector depends on how many variables there are in the model
            slm.SSE = NaN(3,n); % number of lines in this vector depends on how many variables there are in the model
            slm.ef = NaN(2,n);
            slm.sd = NaN(2,n);
        else
            slm.coef = NaN(3,n); % number of lines in this vector depends on how many variables there are in the model
            slm.SSE = NaN(1,n);
            slm.ef = NaN(1,n);
            slm.sd = NaN(1,n);
        end
    end
end

function y = selNumRows(x,numInd)
    y = x(all(numInd,3),:,:);
    if (numel(size(y)) == 3) && (size(y,1) < 10)
        y = x(numInd(:));
    end
end

function c = findNaNCols(co)
    c = any(matCell2Mat(cellfun(@(x)any(isnan(x),1),co,'UniformOutput',false)),1);
end

function [c,indNaN] = remNaNCols(co)
    indNaN = findNaNCols(co);
    if any(indNaN)
        k = ~indNaN;
        c = cellfun(@(x)x(:,k),co,'UniformOutput',false);
    else
        c = co;
    end
end

function c = cellToTerm(co)
    c = cellfun(@(x,y)termSurfStat(x,sprintf('C%d',y)),co,num2cell(1:numel(co)),'UniformOutput',false);
end

function slm = ttestSS(x,y,n_col_max,modelDef,testDomainDef,co,coRaw)
    n_total = size(x,2);
    dim = numel(size(x));
    if n_col_max < n_total
        col1 = 1:n_col_max:n_total;
        col2 = [col1-1,n_total];
        col2(1) = [];
        slm = getEmptySLM();
        n_cols = [];
        for i = 1:numel(col1)
            a = col1(i);
            b = col2(i);
            n_cols(end+1) = numel(a:b);
            [coRaw_cc,co_cc] = getCovariateBetweenCols(coRaw,a,b);
            try
                slm0 = ttestSS_internal(x(:,a:b),y(:,a:b),modelDef,testDomainDef,co_cc,coRaw_cc);
            catch e
                slm0 = getEmptySLM(dim);
            end
            slm = concatSLM(slm,slm0,dim,false);
        end
        slm.df = repeatElements_internal(slm.df,n_cols);
    else
        col1 = 1;
        col2 = n_total;
        slm = ttestSS_internal(x,y,modelDef,testDomainDef,co,coRaw);
    end
end

function slm = ttestSS_internal(x,y,modelDef,testDomainDef,co,coRaw)
    hasNaN = false;
    if ~isempty(co)
        [coRaw,indNaN] = remNaNCols(coRaw);
        hasNaN = any(indNaN);
        if hasNaN
            kk = ~indNaN;
            co = cellToTerm(coRaw);
            x = x(:,kk,:);
            y = y(:,kk,:);
        end
    end
    nObsX = size(x,1);
    nObsY = size(y,1);
    groups = [cellfun(@(a) 'X', cell(nObsX,1), 'UniformOutput', false); cellfun(@(a) 'Y', cell(nObsY,1), 'UniformOutput', false)];
    G = termSurfStat(groups);
    A = cat(1,x,y);
    M = eval(modelDef); % G,co is used in this eval inside the string 'modelDef'
    D = eval(testDomainDef); % G,co is used in this eval inside the string 'testDomainDef'
    slm = SurfStatLinMod(A,M); % model = 1+G; if there's more terms in this model, it will change dimensions of vectors and matrices in slm fields
    slm = SurfStatT(slm,D);
    if ~isempty(co)
        if hasNaN
            slmNaN = getEmptySLM(numel(size(x)),numel(find(~kk)));
            slm = mergeSLM(slm,slmNaN,kk);
        end
    end
end

function [coRaw_cc,co_cc] = getCovariateBetweenCols(coRaw,col1,col2)
    coRaw_cc = cell(size(coRaw));
    co_cc = cell(size(coRaw));
    for i = 1:numel(coRaw)
        coRaw_cc{i} = coRaw{i}(:,col1:col2);
        co_cc{i} = termSurfStat(coRaw_cc{i},sprintf('C%d',i));
    end
end

function [coRaw,co] = getAllCovariates(params)
    i = 0;
    coRaw = cell(1,10);
    co = cell(1,10);
    while true
        i = i + 1;
        [cx,params] = getParamValue(sprintf('C%d_x',i),params,true,[]);
        [cy,params] = getParamValue(sprintf('C%d_y',i),params,true,[]);
        if xor(isempty(cx),isempty(cy))
            error('tTestSurfStat:covariateNotFound','the corresponding covariate of either x or y group has not been found');
        end
        if isempty(cx) && isempty(cy)
            break;
        end
        coRaw{i} = cat(1,cx,cy);
        co{i} = termSurfStat(coRaw{i},sprintf('C%d',i));
    end
    if i < 10
        coRaw(i:end) = [];
        co(i:end) = [];
    end
end

function [modelDef,testDomainDef] = correctModelDefCov(modelDef,testDomainDef,co)
    for i = 1:numel(co)
        modelDef = strrep(modelDef,sprintf('C%d',i),sprintf('co{%d}',i));
        testDomainDef = strrep(testDomainDef,sprintf('C%d',i),sprintf('co{%d}.C%d',i,i));
    end
end

function r = isValidMatrix(M)
    s = size(M);
    r = any(numel(s) == [2,3]) && all(s >= 0);
end

function r = getTailValue(s)
    if isnumeric(s)
        if any(s ~= [-1,0,1])
            error('unrecognized value for Tail parameter; should be -1, 0, or 1; or left, both, or right');
        end
    end
    if strcmpi(s,'both')
        r = 0;
    elseif strcmpi(s,'right')
        r = 1;
    elseif strcmpi(s,'left')
        r = -1;
    else
        error('unrecognized value for Tail parameter; should be -1, 0, or 1; or left, both, or right');
    end
end

function [value,paramList] = getParamValue(parName,paramList,delParam,defaultValue)
    if (nargin < 3) || isempty(delParam)
        delParam = false;
    end
    if (nargin < 4) || isempty(defaultValue)
        defaultValue = [];
    end
    k = find(strcmpi(paramList,parName));
    if isempty(k)
        value = defaultValue;
        return;
    end
    if k == numel(paramList)
        error(['missing parameter value for ', parName]);
    end
    value = paramList{k+1};
    if delParam
        paramList(k:(k+1)) = [];
    end
end

function v = completeToSize_internal(v,sz)
    if isempty(v)
        return;
    end
    m = max(numel(size(v)),numel(sz));
    if all([size(v),ones(1,m-numel(size(v)))] == [sz,ones(1,m-numel(sz))])
        return;
    end
    for i=1:numel(sz)
        v = repToComp_internal(v,sz(i),i);
    end
end

function x = repToComp_internal(x,N,dim)
    n = size(x,dim);
    mm = N/n;
    m = ceil(mm);
    x0 = x;
    for i = 2:m
        x = cat(dim,x,x0);
    end
    if floor(mm) ~= mm
        if dim == 1
            x = x(1:N,:,:);
        elseif dim == 2
            x = x(:,1:N,:);
        elseif dim == 3
            x = x(:,:,1:N);
        else
            s = size(x);
            c = cellfun(@(r)1:r,num2cell(s),'UniformOutput',false);
            c{dim} = 1:N;
            [~,~,~,c] = mymeshgrid(c{:});
            p = 1:numel(c); p(1) = 2; p(2) = 1;
            c = cellfun(@(r)permute(r,p),c,'UniformOutput',false);
            k = sub2ind(size(x),c{:});
            x = x(k);
        end 
        return;
    end
%     m = max(numel(sz),numel(size(v)));
%     s = [size(v),ones(1,m-numel(size(v)))];
%     sz = [sz,ones(1,m-numel(sz))];
%     v = repmat(v,sz);
%     %abs(sz - s + 1)
%     %v = repmat(v,abs(sz-s+1));
end

function xx = repeatElements_internal(x,n)
% n = vector same size as x
% repeats n(i) times each element x(i) and returns it in the same order as in x
    N = sum(n); % total number of elements
    ind = zeros(1,N);
    ind(1:n(1)) = ones(1,n(1));
    s = n(1);
    for k = 2:numel(n)
        ind((s+1):(s+n(k))) = k.*ones(1,n(k));
        s = s + n(k);
    end
    xx = x(ind);
end