function [fh,axh,lh] = plotPlotStruct(axh, pStruct, lineSet, widthSet, symbolSet, colorSet, plotArgs, errArgs, axisArgs, legendArgs, labelArgs, titleArgs)
    if (nargin < 1) || isempty(axh)
        fh=figure;
        axes;
        axh = gca;
    else
        fh = axh.Parent;
    end
    if ((nargin < 3) || (isempty(lineSet)))
        lineSet = { '-' };
    end
    if ((nargin < 4) || (isempty(widthSet)))
        widthSet = 1;
    end
    if ((nargin < 5) || (isempty(symbolSet)))
        symbolSet = 'o^sv+*.xdph<>';
    end
    if ((nargin < 6) || (isempty(colorSet)))
        colorSet = hsv(numel(pStruct.curves));
    end
    if ((nargin < 7) || (isempty(plotArgs)))
        plotArgs = {};
    end
    if ((nargin < 8) || (isempty(errArgs)))
        errArgs = {};
    end
    if ((nargin < 9) || (isempty(axisArgs)))
        axisArgs = {};
    end
    if ((nargin < 10) || (isempty(legendArgs)))
        legendArgs = {};
    end
    if ((nargin < 11) || (isempty(labelArgs)))
        labelArgs = {};
    end
    if ((nargin < 12) || (isempty(titleArgs)))
        titleArgs = {};
    end

    getLineSt = @(ii)getPLine(ii,lineSet);
    getColor = @(ii)getPColor(ii,colorSet);
    getSymbol = @(ii)getPSymbol(ii,symbolSet);
    getWidth = @(ii)widthSet(int32(mod(int32(ii)-1,numel(widthSet)))+1);
    
    [val, errArgs, co] = getArgValue(errArgs, 'showerrorbar');
    if (~co)
        showErrorBar = true;
    else
        showErrorBar = strcmpi(val, 'on');
    end
    [errBarFill,errArgs,co] = getArgValue(errArgs, 'fill');
    if ~co
        errBarFill = false;
    else
        errBarFill = strcmpi(errBarFill, 'on');
    end
    [errLineSpec,errArgs] = getArgValue(errArgs, 'linespec');
    [errLineColor,errArgs,co] = getArgValue(errArgs, 'color');
    if ~co
        errLineColor = 'k';
    end
    errLineColorAuto = false;
    if strcmpi(errLineColor, 'auto')
        errLineColorAuto = true;
    end
    [plotLineSpec,plotArgs,emptyLineSpec] = getArgValue(plotArgs, 'linespec');
    emptyLineSpec = ~emptyLineSpec;
    
    isXLogScale = strcmpi(pStruct.xScale,'log');
    isYLogScale = strcmpi(pStruct.yScale,'log');
    
    hold(axh, 'all');
    nC = numel(pStruct.curves);
    lh = cell(1, nC);
    %hv = [];
    for i = 1:nC
        if (emptyLineSpec)
            plotLineSpec = [getLineSt(i),getSymbol(i)];
        end
        if (pStruct.curves(i).showLegend)
            legvis = 'on';
        else
            legvis = 'off';
        end
        if (showErrorBar && ~isempty(pStruct.curves(i).yErr))
            if errLineColorAuto
                errLineColor = getColor(i);
            end
            lh{i}=plotErrAx(axh, pStruct.curves(i).x, pStruct.curves(i).y, [], [pStruct.curves(i).yErr.L(:),pStruct.curves(i).yErr.U(:)],...
                plotLineSpec, errLineSpec,...
                [ { 'LineWidth', getWidth(i), 'Color', getColor(i), 'MarkerFaceColor', getColor(i), 'HandleVisibility', legvis } plotArgs ],...
                [ { 'Color', errLineColor, 'Fill', errBarFill }, errArgs ],isXLogScale,isYLogScale);
        else
            hold(axh, 'all');
            temp = [ { 'LineWidth', getWidth(i), 'Color', getColor(i), 'MarkerFaceColor', getColor(i), 'HandleVisibility', legvis } plotArgs ];
            lh{i} = plot(axh, pStruct.curves(i).x, pStruct.curves(i).y, plotLineSpec, temp{:});
        end
        %hv((numel(hv)+1):(numel(hv)+numel(h{i})-1)) = h{i}(1:(end-1));
    end
    for i = 1:nC
        if ~isempty(lh{i})
            uistack(lh{i}(end), 'top');
        end
        %hv(end+1) = h{i}(end);
    end
    %uistack(hv);
    hold(axh, 'off');
    if (~isempty(axisArgs))
        set(axh, axisArgs{:});
    end
    legInd = logical([pStruct.curves(:).showLegend]);
    if (any(legInd))
        if useLaTeXInterpreter(pStruct.legend(legInd))
            legendArgs = ['Interpreter','latex',legendArgs];
        end
        legend(axh, pStruct.legend(legInd), legendArgs{:});
    end
    [xld,labelArgs] = getArgValue(labelArgs, 'xdisplacement');
    [yld,labelArgs] = getArgValue(labelArgs, 'ydisplacement');
    if useLaTeXInterpreter(pStruct.xLabel)
        xlh = xlabel(axh, 'temp', 'Interpreter', 'latex');
        xLabelArgs = [ 'Interpreter', 'latex', labelArgs ];
    else
        xLabelArgs = labelArgs;
    end
    if useLaTeXInterpreter(pStruct.yLabel)
        ylh = ylabel(axh, 'temp', 'Interpreter', 'latex');
        yLabelArgs = [ 'Interpreter', 'latex', labelArgs ];
    else
        yLabelArgs = labelArgs;
    end
    xlh = xlabel(axh, pStruct.xLabel, 'Units', 'Normalized', xLabelArgs{:});
    ylh = ylabel(axh, pStruct.yLabel, 'Units', 'Normalized', yLabelArgs{:});
    xlp = get(xlh, 'Position');
    ylp = get(ylh, 'Position');
    if isempty(xld)
        xld = zeros(1,3);
    end
    if isempty(yld)
        yld = zeros(1,3);
    end
    set(xlh, 'Position', xlp + xld);
    set(ylh, 'Position', ylp + yld);
    set(axh, 'XScale', pStruct.xScale, 'YScale', pStruct.yScale);
    if isfield(pStruct, 'title')
        if ~isempty(pStruct.title)
            [titleDispl,titleArgs] = getArgValue(titleArgs, 'displacement');
            [titleUnits,titleArgs] = getArgValue(titleArgs, 'units');
            th = title(axh, pStruct.title);
            if ~isempty(titleUnits)
                set(th, 'Units', titleUnits);
            end
            if ~isempty(titleDispl)
                th.Position = th.Position + titleDispl;
            end
            if ~isempty(titleArgs)
                set(th, titleArgs{:});
            end
        end
    end
    %lh = axh;
end

function r = useLaTeXInterpreter(s)
    if iscell(s)
        r = false;
        for i = 1:numel(s)
            if useLaTeXInterpreter_internal(s{i})
                r = true;
                return;
            end
        end
    else
        r = useLaTeXInterpreter_internal(s);
    end
end

function r = useLaTeXInterpreter_internal(s)
    ss = sum(s == '$');
    r = (ss ~= 0) && (mod(ss,2) == 0);
end

function [val,argsOut,c] = getArgValue(args, arg)
    argsOut = args;
    ind = find(strcmpi(strCellToLower(args),arg));
    if (~isempty(ind))
        val = argsOut{ind+1};
        argsOut(ind+1) = [];
        argsOut(ind) = [];
        c = true;
    else
        val = [];
        c = false;
    end
end

function s = getPLine(ii, lineSet)
    s = lineSet{int32(mod(int32(ii)-1,numel(lineSet)))+1};
    if ((strcmp(s,'n')) || (strcmp(s,'none')))
        s = '';
    end
end

function s = getPSymbol(ii, symbolSet)
    s = symbolSet(int32(mod(int32(ii)-1,numel(symbolSet)))+1);
    if ((strcmp(s,'n')) || (strcmp(s,'none')))
        s = '';
    end
end

function s = getPColor(ii, colorSet)
    s = colorSet(int32(mod(int32(ii)-1,int32(round(numel(colorSet)/3))))+1,:);
end

function cc = strCellToLower(c)
    n = numel(c);
    cc = cell(size(c));
    for i = 1:n
        if (isstr(c{i}))
            cc{i} = lower(c{i});
        else
            cc{i} = c{i};
        end
    end
end

function hv = plotErrAx(axh, x, y, xe, ye, lineS, errLineS, plotArgs, errArgs, isXLogScale, isYLogScale)
%ploterr(gca, parPlot.curves(1).x, parPlot.curves(1).y, [], [parPlot.curves(1).yErr.L(:),parPlot.curves(1).yErr.U(:)]);
    x = x(:);
    y = y(:);
    nD = numel(x);

    hasXErr = ~isempty(xe);
    hasPlotArgs = nargin >= 8 && ~isempty(plotArgs);
    hasErrArgs = nargin >= 9 && ~isempty(errArgs);
    if ((nargin < 6) || (isempty(lineS)))
        lineS = '-b';
    end
    if ((nargin < 7) || (isempty(errLineS)))
        errLineS = '';
    end
    [errBarFill,errArgs] = getArgValue(errArgs, 'fill');
    [faceAlpha,errArgs,co] = getArgValue(errArgs, 'facealpha');
    if ~co
        faceAlpha = 0.2;
    end
    [errLineColor,~] = getArgValue(errArgs,'color');
    fill_between_lines = @(X,Y1,Y2,C) fill( [X(:)' fliplr(X(:)')],  [Y1(:)' fliplr(Y2(:)')], C, 'EdgeColor','none','FaceAlpha',faceAlpha,'HandleVisibility','off');
    
    [mm,nn] = size(ye);
    if (nn == nD)
        ye = ye';
    end
    if (mm == 1)
        yeb = ye;
        yet = ye;
    else
        yeb = ye(:,1);
        yet = ye(:,2);
    end
    if (hasXErr)
        [mm,nn] = size(xe);
        if (nn == nD)
            xe = xe';
        end
        if (mm == 1)
            xel = xe;
            xer = xe;
        else
            xel = xe(:,1);
            xer = xe(:,2);
        end
    end

    hv = [];
    hold(axh, 'all');
    if errBarFill
        yErrB = y - yeb;
        yErrT = y + yet;
        if isYLogScale
            yErrB(yErrB<=0) = y(yErrB<=0) - y(yErrB<=0)./1.01;%min(yErrB(yErrB>0)); %y(yErrB<=0) - 10.^(floor(log10(y(yErrB<=0))));%1/realmax
        end
        hv(end+1) = fill_between_lines(x,yErrB,yErrT,errLineColor);
        if (hasErrArgs)
            hv(end+1) = plot(axh, x, yErrB, errLineS, 'HandleVisibility', 'off', errArgs{:});
            hv(end+1) = plot(axh, x, yErrT, errLineS, 'HandleVisibility', 'off', errArgs{:});
        else
            hv(end+1) = plot(axh, x, yErrB, errLineS, 'HandleVisibility', 'off');
            hv(end+1) = plot(axh, x, yErrT, errLineS, 'HandleVisibility', 'off');
        end
    else
        for i = 1:nD
            if (hasXErr)
                if (hasErrArgs)
                    hv(end+1) = plot(axh, [(x(i) - xel(i)) (x(i) + xer(i))], [y(i) y(i)], errLineS, 'HandleVisibility', 'off', errArgs{:});
                else
                    hv(end+1) = plot(axh, [(x(i) - xel(i)) (x(i) + xer(i))], [y(i) y(i)], errLineS, 'HandleVisibility', 'off');
                end
                %uistack(h1, 'bottom');
            end
            if (hasErrArgs)
                hv(end+1) = plot(axh, [x(i) x(i)], [(y(i) - yeb(i)) (y(i) + yet(i))], errLineS, 'HandleVisibility', 'off', errArgs{:});
            else
                hv(end+1) = plot(axh, [x(i) x(i)], [(y(i) - yeb(i)) (y(i) + yet(i))], errLineS, 'HandleVisibility', 'off');
            end
            %uistack(h2, 'bottom');
        end
    end

    if (hasPlotArgs)
        hv(end+1) = plot(axh, x, y, lineS, plotArgs{:});
    else
        hv(end+1) = plot(axh, x, y, lineS);
    end
    hold(axh, 'off');
end
