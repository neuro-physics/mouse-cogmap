function s = getParamString(p,breakLine,omitParams,parPrecision,forFileName)
    if (nargin < 2) || isempty(breakLine)
        breakLine = false;
    end
    if (nargin < 3) || isempty(omitParams)
        omitParams = {};
    end
    if (nargin < 4) || isempty(parPrecision)
        parPrecision = '%g';%'%.2f'; % either a string, so its applied to all param, or a cell of cells and str
        % if cell of cells and str, then if any element, an str element is applied to all param, except
        % for those defined inside a cell element of the type {'par','precision'}
        % e.g.
        % parPrecision = {'%.2f',{'sf','%.3f'}};
        % applies %.2f to all params, except for 'sf', which will be %.3f
    end
    if (nargin < 5) || isempty(forFileName)
        forFileName = false;
    end
    
    assert(isValidPrecision(parPrecision),'parPrecision is either a char or a cell of char and cells... see function definition for detailsl');
    
    [n,v] = getScalarFieldsValue(p);
    %parToKeep = {'w','alpha','xi','nu'};
    %n(k) = [];
    %v(k) = [];
    c = cellfun(@(x,y) ['$',replaceGreekLetters(x),'=',correctInf(num2str(y,getPrecision(x,parPrecision)),forFileName),'$'],n,num2cell(v),'UniformOutput',false);
    if ~isempty(omitParams)
        if ~iscell(omitParams)
            omitParams = {omitParams};
        end
        [~,k] = intersect(n,omitParams);
        c(k) = [];
    end
    s = strjoin(c,', ');
    if forFileName
        s = strrep(strrep(strrep(strrep(strrep(s,'s_f','sf'),'=',''),'\',''),'$',''),', ','_');
    end
    if breakLine
        if isnumeric(breakLine)
            n = breakLine;
        else
            n = floor(numel(c)/2);
        end
        ss = strsplit(s,', ');
        if breakLine == -1
            s = ss;
        else
            s = strjoin(ss(1:n),', ');
            if n < numel(ss)
                s={s,strjoin(ss((n+1):end),', ')};
            end
        end
    end
end

function s = correctInf(txt,forFileName)
    if forFileName
        s = txt;
    else
        s = strrep(txt,'Inf','\infty');
    end
end

function s = replaceGreekLetters(s)
    s = strrep(strrep(strrep(strrep(strrep(s,'xi','\xi'),'tau','\tau'),'nu','\nu'),'alpha','\alpha'),'omega','\omega');
end

function [n,v] = getScalarFieldsValue(p)
    f = fieldnames(p);
    n = {};
    v = [];
    for i = 1:numel(f)
        if isValidParam(p.(f{i}))%(numel(p.(f{i})) == 1)
            n{end+1} = f{i};
            v(end+1) = p.(f{i});
        end
    end
end

function r = isValidParam(c)
    r = isscalar(c) && isnumeric(c);
end

function r = isValidPrecision(c)
    r = ischar(c)...
        || (iscell(c) && all(cellfun(@isValidElement,c)));
end

function r = isValidElement(c)
    r = ischar(c) || (iscell(c) && (numel(c) == 2) && ischar(c{1}) && ischar(c{2}));
end

function p = getPrecision(par,c)
    if ischar(c)
        p = c;
    else
        k = find(cellfun(@ischar,c),1,'first');
        k1 = find(cellfun(@(x)~ischar(x)&&strcmpi(x{1},par),c),1,'first');
        if isempty(k1)
            if isempty(k)
                p = '%.2f';
            else
                p = c{k};
            end
        else
            p = c{k1}{2};
        end
    end
end