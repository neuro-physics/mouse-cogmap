function ax = plot_time_to_food(si_exp,si_th,si_th_param,normalize_run_trials,cMap)
    if (nargin < 4) || isempty(normalize_run_trials)
        normalize_run_trials = true;
    end
    if (nargin < 5) || isempty(cMap)
        cMap = @winter;
    end

    assert(isfield(si_th(1),si_th_param),'si_th_param must be a numeric and scalar field of si_th');
    assert(isnumeric(si_th(1).(si_th_param)) && isscalar(si_th(1).(si_th_param)),'si_th_param must be a numeric and scalar field of si_th');
    
    if ~isfield(si_exp.learning_stage(1),'trial')
        si_exp = import.import_mouse_stepmat(si_exp.fileName,true);
    end

    xLabel = 'Run trial';
    if normalize_run_trials
        xLabel = 'Run trial (normalized)';
    end
    
    if normalize_run_trials
        x = linspace(0,1,numel(si_exp.learning_stage));
    else
        x = 1:numel(si_exp.learning_stage);
    end
    y = arrayfun(@(a)mean([a.trial(:).t_food]),si_exp.learning_stage);
    yErr = arrayfun(@(a)stderr(double([a.trial(:).t_food])),si_exp.learning_stage);
    ps_exp = plot_func.getPlotStruct({x}, {y}, {yErr}, xLabel, '$T$', 'linear', 'log', '', {'Mice'}, 1, '');
    
    param_values = [si_th(:).(si_th_param)];
    y = arrayfun(@(s)arrayfun(@(tr)mean(tr.t_food),s.traj),si_th,'UniformOutput',false);
    yErr = arrayfun(@(s)arrayfun(@(tr)stderr(tr.t_food),s.traj),si_th,'UniformOutput',false);
    if normalize_run_trials
        x = repmat({  linspace(0,1,numel(y{1}))   },size(y));
    else
        x = repmat({1:numel(y{1})},size(y));
    end
    ps_th = plot_func.getPlotStruct(x, y, yErr, xLabel, '$T$', 'linear', 'log', replaceGreekLetters(si_th_param), param_values, 1, '');
    
    ps = plot_func.mergePlotStruct(ps_exp,ps_th);
    fig_prop = plot_func.getDefaultFigureProperties();
    
    nCurves = numel(ps.curves);
    
    % plot symbols (o for experiments, no symbol for simulation)
    ppSym = ['o',func.repeatToComplete(fig_prop.pSymbols(2:end),nCurves-1)];
    % colors
    if isa(cMap,'function_handle')
        cMap = cMap(nCurves - 1);
    else
        cMap = func.expandMatrix(cMap,[(nCurves-1),3]);
    end
    ppCol = [0,0,0; cMap];
    ppWid = [2,func.repeatToComplete(0.1,nCurves-1)];
    ppLin = [{ ':' },func.repeatToComplete({'--'},nCurves-1)];
    
    [~,ax,~] = plot_func.plotPlotStruct([], ps, ppLin, ppWid, ppSym, ppCol, ...
            {'MarkerSize', fig_prop.pPointSize, 'MarkerFaceColor', 'auto'},... % plot properties % 'LineWidth', fig_prop.pLineWidth
            {'ShowErrorBar', 'on', 'Color', 'auto', 'Fill', 'on', 'LineStyle', 'none'},... % error properties
            {'Box', 'on', 'Layer', 'top'},... % axis properties
            {'Location', 'eastoutside', 'FontSize', 8, 'Box', 'off', 'Interpreter', 'latex'},... % legend properties
            {'FontSize', 12}); % label properties
%     ax.Children(end).DisplayName = 'Mice';
    uistack(ax.Children(end),'top');
end

function s = stderr(x)
    s = std(x) ./ sqrt(numel(x));
end

function s = replaceGreekLetters(s)
    s = strrep(strrep(strrep(strrep(strrep(s,'xi','\xi'),'tau','\tau'),'nu','\nu'),'alpha','\alpha'),'omega','\omega');
end