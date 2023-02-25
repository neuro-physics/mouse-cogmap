function r = ttest2Struct(x_c,x_p,varargin)
% varargin -> all the params for ttest2 function
% additional params:
%    AlphaFDR    -> value for the FDR threshold
%    SplitNegPos -> averages x and y across rows and performs two t-Tests:
%                   one for the elements in which: mean(x,1) - mean(y,1) >= 0; and the other for difference < 0
%    TTestLines  -> x and y are 3d-arrays (matrix stacks); t-test each line stack of x, x(i,:,:), against each corresponding line stack of y, y(i,:,:)
%    MultiVar    -> multivariate t-test (uses SurfStat); x and y must be 3d-arrays, being each variate a different 3rd coordinate in them; x(:,:,1),y(:,:,1) = variate 1, and so on; size(x,1) -> observations; size(x,2) -> values of variables of a given type; size(x,3) -> types of variables (variates)
    if nargin == 0
        r = ttest2Struct_internal();
        return;
    end
    
    try
        r = ttest2Struct_full(x_c,x_p,[],varargin);
    catch ME
        if (strcmp(ME.identifier,'SurfStat:ContrastNotEstimable'))
            r = ttest2Struct_full(x_c,x_p,50,varargin);
            return
        end
        rethrow(ME);
    end
end

function r = ttest2Struct_full(x_c,x_p,n_col_max,args)
    if isempty(n_col_max)
        n_col_max = size(x_c,2);
    end
    [splitTTest,params] = getParamValue('SplitNegPos',args,true);
    [ttestLines,params] = getParamValue('TTestLines',params,true);
    [multiVar,params] = getParamValue('MultiVar',params,true);
    [hasModel,~] = getParamValue('Model',params,false);

    if isParamTrue(multiVar)
        if (numel(size(x_c)) == numel(size(x_p))) && (numel(size(x_c)) ~= 3)
            error('x and y must be matrices with different variates in the third dimension');
        end
        splitTTest = false;
        ttestLines = false;
        params = [params,'MultiVar',true];
    end
    
    if ~isempty(hasModel)
        splitTTest = false;
        ttestLines = false;
    end

    if isParamTrue(ttestLines)
        if (numel(size(x_c)) == numel(size(x_p))) && (numel(size(x_c)) ~= 3)
            error('x and y have to be a matrix stack (each entry in the stack is an observation for the i,j element of x and y)');
        end
        % x and y are matrix stacks (stacked over in depth direction size(x,3))
        n = size(x_c,1);
%         error('not implemented')
        r = ttest2Struct_internal(n*n);
        for i = 1:n
            % t-test each line stack of x against the corresponding line stack of y
            xx = reshape(x_c(i,:,:),size(x_c,2),size(x_c,3))';
            yy = reshape(x_p(i,:,:),size(x_p,2),size(x_p,3))';
            t1 = ttest2Struct_wrapper(xx,yy,splitTTest,[],params);
            r = copyTTestStruct(t1, i:n:(n*n), r);
%             r = copyTTestStruct(t1, (1:n)+(i-1)*n, r); % the reshape generates the matrix per column, so these indices would generate a transposed matrix

        end
    else
        r = ttest2Struct_wrapper(x_c,x_p,splitTTest,n_col_max,params);
    end
end

function r = ttest2Struct_wrapper(x,y,splitTTest,n_col_max,params)
    k = (mean(x,1) - mean(y,1)) >= 0;
%     disp(['size x = ',mat2str(size(x))]);
%     disp(['size y = ',mat2str(size(x))]);
    if isParamTrue(splitTTest)
        kk = find(k);
%         fprintf('numel find k  = %d\n', numel(kk));
%         fprintf('numel find ~k = %d\n', numel(find(~k)));
%         if (numel(kk) > 3) && (numel(find(~k)) > 3)
        if numel(kk) >= 1
            t1 = ttest2Struct_internal(x(:,k),y(:,k),[params,'Tail','right']); % t-testing where <x> > <y>; thus t is positive, so we t-test from the right t-distribution
            if numel(kk) == numel(k)
                r = t1;
            else
                t2 = ttest2Struct_internal(x(:,~k),y(:,~k),[params,'Tail','left']); % t-testing where <x> < <y>; t is negative, then testing from the left t-distribution
                r = mergeTTestStruct(t1, t2, k);
            end
        else
            r = ttest2Struct_internal(x,y,n_col_max,params);
        end
    else
        r = ttest2Struct_internal(x,y,n_col_max,params);
    end
end

function r = isParamTrue(v)
    r = ~isempty(v);
    if ischar(v)
        r = r && strcmpi(v, 'on');
    else
        r = r && ((v == 1) || (v == true));
    end
end

function r = mergeTTestStruct(t1,t2,k)
%     if (nargin < 3) || isempty(k)
%         k = numel(t1.h) + numel(t2.h);
%         r = ttest2Struct_internal(k);
%         k1 = [true(1,numel(t1.h)),false(1,numel(t2.h))];
%         r = copyTTestStruct(t1, k1, r);
%         r = copyTTestStruct(t2, ~k1, r);
%     else
    r = ttest2Struct_internal(numel(k));
    k1 = k == 1;
    r = copyTTestStruct(t1, k1, r);
    r = copyTTestStruct(t2, ~k1, r);
%     end
end

function r = copyTTestStruct(s,k,r)
% copies s into positions k of r
% k is a logical vector
    r.h(k) = s.h;
    r.p(k) = s.p;
    r.t(k) = s.t;
    r.hFDR(k) = s.hFDR;
    r.Cohen_Mahal(k) = s.Cohen_Mahal;
    r.effsz(k) = s.effsz;
    r.confInt(:,k) = s.confInt;
%     disp('size s.confInt')
%     disp(mat2str(size(s.confInt)));
%     disp('size find k')
%     disp(mat2str(size(find(k))));
%     disp('size r.confInt')
%     disp(mat2str(size(r.confInt)))
%     disp('size k')
%     disp(mat2str(size(k)))
    r.stats.tstat(k) = s.stats.tstat;
    r.stats.df(k) = s.stats.df;
    r.stats.sd(k) = s.stats.sd;
    r.pFDR = s.pFDR;
    r.alpha = s.alpha;
    r.alphaFDR = s.alphaFDR;
end

function r = ttest2Struct_internal(x_c,x_p,n_col_max,params)
    r = struct('h',[],'p',[],'t',[],'Cohen_Mahal',[],'effsz',[],'hFDR',[],'pFDR',[],'confInt',[],'stats',[],'alpha',[],'alphaFDR',[]);
    if nargin == 0
        return;
    elseif nargin == 1
        if isscalar(x_c)
            r.h = zeros(1,x_c);
            r.p = zeros(1,x_c);
            r.t = zeros(1,x_c);
            r.Cohen_Mahal = zeros(1,x_c);
            r.effsz = zeros(1,x_c);
            r.hFDR = zeros(1,x_c);
            r.confInt = zeros(2,x_c);
            r.stats = struct('tstat', zeros(1,x_c), 'df', zeros(1,x_c), 'sd', zeros(1,x_c));
        else
            error('unrecognized input');
        end
        return;
    end
    sx = size(x_c);
    sy = size(x_p);
    if sx(1) == 1
        x_c = repmat(x_c,2,1);
    end
    if sy(1) == 1
        x_p = repmat(x_p,2,1);
    end
    
    alpha = getParamValue('Alpha',params);
    [alphaFDR,params] = getParamValue('AlphaFDR',params,true);
    [multiVar,params] = getParamValue('MultiVar',params,true);
    [hasModel,~] = getParamValue('Model',params);
    [useSurfStat,params] = getParamValue('UseSurfStat',params,true);
    if isempty(alpha)
        alpha = 0.05;
    end
    if isempty(alphaFDR)
        alphaFDR = alpha;
    end
    if isempty(useSurfStat)
        useSurfStat = true;
    end

    if isParamTrue(useSurfStat) || (isParamTrue(multiVar) || ~isempty(hasModel))
        params = [params, 'Tail', 'both', 'N_cols_max',n_col_max];
        [h,p,ci,st,t,slm] = ttest.tTestSurfStat(x_c,x_p,params{:});
    else
        [h,p,ci,st,t] = ttest.myttest2(x_c,x_p,params{:});
        slm = struct('ef',NaN(size(h)));
    end
    h(isnan(h)) = 0; % if h is NaN, it means that the T-test ratio is 0/0: the mean difference is 0 and the std dev of both sets are 0 too.
    [pFDR,~] = FDR(p,alphaFDR);
    if alpha < pFDR
        pFDR = alpha;
    end
    hFDR = p <= pFDR;
    r.h = h;
    r.p = p;
    r.t = t;
    if ndims(x_c) == 3
        r.Cohen_Mahal = ttest.mahalsqrt(x_c,x_p);
    else
        r.Cohen_Mahal = ttest.computeCohen_d(x_c,x_p,'independent');
    end
    r.effsz = slm.ef;
    r.hFDR = hFDR;
    r.pFDR = pFDR;
    r.confInt = ci;
    r.stats = st;
    r.alpha = alpha;
    r.alphaFDR = alphaFDR;
end

function [value,paramList] = getParamValue(parName,paramList,delParam)
    if (nargin < 3) || isempty(delParam)
        delParam = false;
    end
    k = find(strcmpi(paramList,parName));
    if isempty(k)
        value = [];
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