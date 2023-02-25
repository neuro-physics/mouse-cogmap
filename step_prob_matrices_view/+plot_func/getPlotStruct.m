function s = getPlotStruct(x, y, yErr, xLabel, yLabel, xScale, yScale, legendParName, legendParValues, showLegend, plotTitle)
% xScale -> 'linear', 'log' or 'bar'
%           if 'bar', then values on x are given such that the plot looks like a 'bar plot', with each x{i} y{i} being a bar
    if (nargin == 0)
        s.curves = getCurvePlot();
        s.xLabel = [];
        s.yLabel = [];
        s.xScale = [];
        s.yScale = [];
        s.legend = [];
        s.legendValues = [];
        s.title = [];
    else
        if isempty(yErr)
            yErr = cell(size(y));
        end
        if isempty(xScale)
            xScale = 'linear';
        end
        if isempty(yScale)
            yScale = 'linear';
        end
        if ((nargin < 10) || (isempty(showLegend)))
            showLegend = true;
        end
        if ((nargin < 11) || isempty(plotTitle))
            plotTitle = '';
        end
        if (iscell(x))
            [x,xScale] = rescaleX(x, xScale);
            if (isscalar(showLegend))
                showLegend = repmat(showLegend, 1, numel(x));
            end
            n = numel(x);
            s.curves = repmat(getCurvePlot(), 1, n);
            for i = 1:n
                s.curves(i) = getCurvePlot(x{i}, y{i}, yErr{i}, showLegend(i));
            end
        else
            s.curves = getCurvePlot(x, y, yErr, showLegend);
        end
        s.xLabel = xLabel;
        s.yLabel = yLabel;
        s.xScale = xScale;
        s.yScale = yScale;
        s.legend = getLegendCellArr(legendParName, legendParValues);
        s.legendValues = legendParValues;
        s.title = plotTitle;
    end
end

function [x,xScale] = rescaleX(xx, xScale)
    if strcmpi(xScale, 'linear') || strcmpi(xScale, 'log')
        x = xx;
    else
        xScale = 'linear';
        nC = numel(xx);
        x = cell(size(xx));
        for i = 1:nC
            n = numel(xx{i});
            if (n > 1)
                dx = 1 / (n - 1);
                x{i} = ((i-1):dx:i) + i - 1;
            else
                x{i} = i - 0.5;
            end
        end
    end
end

function s = getCurvePlot(x, y, yErr, showLegend)
    if (nargin == 0)
        s.x = [];
        s.y = [];
        s.yErr = getErrorStruct();
        s.showLegend = false;
    else
        s.x = x;
        s.y = y;
        if (~isempty(yErr))
            [m,n] = size(yErr);
            if (m == 1) || (n == 1)
                s.yErr = getErrorStruct(yErr);
            else
                if m == 2
                    yErr = yErr';
                end
                s.yErr = getErrorStruct(yErr(:,1), yErr(:,2));
            end
        else
            s.yErr = [];
        end
        s.showLegend = showLegend;
    end
end

function c = getLegendCellArr(n, v)
    m = numel(v);
    c = cell(1,m);
    isc = iscell(v);
    for i = 1:m
        if isempty(n)
            pref = '';
        else
            pref = [n,'='];
        end
        if isc
            c{i} = [ pref, v{i} ];
        else
            c{i} = [ '$', pref , num2str(v(i)), '$' ];
        end
    end
end

function s = getErrorStruct(L,U)
    if (nargin > 1)
        s.L = L(:)';
        s.U = U(:)';
    elseif (nargin == 1)
        s.L = L(:)';
        s.U = s.L;
    else
        s.L = [];
        s.U = [];
    end
end
