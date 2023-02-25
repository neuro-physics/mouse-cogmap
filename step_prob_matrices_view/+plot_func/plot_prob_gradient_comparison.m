function ax = plot_prob_gradient_comparison(si_exp,si_th,nPanel_per_row,mouse_idx,use_grid_visits_as_color,force_cumulative_prob,plot_label_theory)
    if (nargin < 3) || isempty(nPanel_per_row)
        nPanel_per_row = 4;
    end
    if (nargin < 4) || isempty(mouse_idx)
        mouse_idx = NaN;
    end
    if (nargin < 5) || isempty(use_grid_visits_as_color)
        use_grid_visits_as_color = false;
    end
    if (nargin < 6) || isempty(force_cumulative_prob)
        force_cumulative_prob = false;
    end
    if (nargin < 7) || isempty(plot_label_theory)
        plot_label_theory = '';
    end
    
    assert(nPanel_per_row>2,'nPanel_per_row must be greater than 2');
    assert(isfield(si_exp.learning_stage(1),'mouse'),'si_exp must be in the ''mouse struct'' format');
    
    th_field = plot_label_theory;
    if isempty(plot_label_theory)
        if force_cumulative_prob || strcmpi(si_exp.probability_calculation,'cumulative_prob')
            th_field = 'sites_per_run_cprob';
        else
            th_field = 'sites_per_run';
        end
    end
    if any(strcmpi(th_field,{'P_indpt','P_cprob'}))
        for i = 1:numel(si_th)
            si_th(i).sites_per_run = arena.prob_matrix_to_site_struct(si_th(i),th_field);
        end
        th_field = 'sites_per_run';
    end
    
    fig_pos = [100,100,1200,600];
    nRows = numel(si_th) + 1; % first row is experimental, other rows are simulations
    if nRows > 2
        screeSize = get(0,'ScreenSize');
        fig_pos = [100,0,1200,screeSize(4)-80];
    end
    
    ind_exp = unique(round(linspace(1,numel(si_exp.sites_per_stage),nPanel_per_row)));
    nPanel_per_row = numel(ind_exp); % the number of unique panels from the experiments may have chaned due to unique(round())
    
    fig = figure('Position',fig_pos);
    ax_exp = gobjects(1,nPanel_per_row);
    for i = 1:nPanel_per_row
        figure(fig);
        ax_exp(i) = subplot(nRows,nPanel_per_row,i);
        if isnan(mouse_idx)
            sites_exp = si_exp.sites_per_stage{ind_exp(i)};
        else
            sites_exp = si_exp.learning_stage(ind_exp(i)).mouse(mouse_idx).sites;
        end
        arena.plot_prob_gradient(ax_exp(i),sites_exp,si_exp.simParam,use_grid_visits_as_color);
        n_trials = numel(si_exp.learning_stage(ind_exp(i)).mouse(1).trial);
        %title(ax_exp(i),sprintf('stage %d (%d trials)',ind_exp(i),n_trials),'FontWeight','normal');
        title(ax_exp(i),sprintf('Trial %d',ind_exp(i)),'FontWeight','normal');
    end
    ylabel(ax_exp(1),'Experiment');
    set_panel_group_title(fig,ax_exp,sprintf('Prob. calc. method: %s',si_exp.probability_calculation));
    ax_sim = gobjects(nRows-1,nPanel_per_row);
    for k = 1:numel(si_th)
        ind_th = round(linspace(1,numel(si_th(k).(th_field)),nPanel_per_row));
        for i = 1:nPanel_per_row
            figure(fig);
            ax_sim(k,i) = subplot(nRows,nPanel_per_row,k*nPanel_per_row+i);
            arena.plot_prob_gradient(ax_sim(k,i),si_th(k).(th_field){ind_th(i)},si_th(k).simParam,use_grid_visits_as_color);
            title(ax_sim(k,i),sprintf('run %d',ind_th(i)),'FontWeight','normal');
        end
        ylabel(ax_sim(k,1),'Simulation');
        set_panel_group_title(fig,ax_sim(k,:),func.getParamString(si_th(k)),{'Interpreter','latex'});
    end
    ax = [ax_exp;ax_sim];
end

function set_panel_group_title(fig,ax,txt,annotationArgs)
    if (nargin < 4) || isempty(annotationArgs)
        annotationArgs = {};
    end
    x = ax(1).Position(1);
    y = ax(1).Position(2) + ax(1).Position(4) + 0.025;
    w = ax(end).Position(3)+ax(end).Position(1)-ax(1).Position(1);
    annotation(fig,'textbox',[x, y, w, 0.0244897959183669],'String',txt,'VerticalAlignment','bottom','Margin',0,'HorizontalAlignment','center','FitBoxToText','off','LineStyle','none',annotationArgs{:});
end