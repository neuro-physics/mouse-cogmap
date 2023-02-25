function [lh,th,mm] = annotate_ttest_data(ax,x1,x2,y_level,capSize,y_symbol_mult,label,symbol,labelArgs,symbolArgs,lineArgs)
    if (nargin < 5) || isempty(capSize)
        capSize = 2;
    end
    if (nargin < 6) || isempty(y_symbol_mult)
        y_symbol_mult = 2;
    end
    if (nargin < 7) || isempty(label)
        label = '';
    end
    if (nargin < 8) || isempty(symbol)
        symbol = '*';
    end
    if (nargin < 9) || isempty(labelArgs)
        labelArgs = {};
    end
    if (nargin < 10) || isempty(symbolArgs)
        symbolArgs = {};
    end
    if (nargin < 11) || isempty(lineArgs)
        lineArgs = {};
    end
    x = [       x1       ,   x1   ,   x2   ,       x2        ];
    y = [ y_level+capSize, y_level, y_level, y_level+capSize ];
    lh = line(ax,x,y,lineArgs{:});
    
    y_symbol_label = y_level-y_symbol_mult*capSize;
    if isempty(label)
        th = plot(ax, (x1+x2)/2, y_symbol_label, symbol, symbolArgs{:});
    else
        th = text(ax, (x1+x2)/2, y_symbol_label, label, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', labelArgs{:});
    end
    
    mm = y_symbol_label;

end