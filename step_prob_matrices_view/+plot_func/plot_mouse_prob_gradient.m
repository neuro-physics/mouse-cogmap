function [ax,G] = plot_mouse_prob_gradient(mouse_step_prob_struct,learning_stage_ind,nPanel_per_row,mouse_idx,...
                                       use_grid_visits_as_color,force_cumulative_prob,fig_size,gradient_cmap,...
                                       quiverArgs,pcolorArgs,startArgs,targetArgs,arenaArgs,...
                                       showLattice,latticeArgs,...
                                       showPreviousTarget,prevTargetArgs,showGradientMagnitude,arena_outside_patch_args,...
                                       mouse_step_prob_struct_jackknife,show_jk_avg,calc_significant_path_args,use_color_quiver,...
                                       show_holes,holesArgs)
    if isempty(mouse_step_prob_struct)
        error('plot_mouse_prob_gradient:mouse_step_prob_struct','empty mouse_step_prob_struct variable');
    end
    if (nargin < 2) || isempty(learning_stage_ind)
        learning_stage_ind = 1:numel(mouse_step_prob_struct.learning_stage);
    end
    if (nargin < 3) || isempty(nPanel_per_row)
        nPanel_per_row = min(numel(learning_stage_ind),4);
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
    if (nargin < 7) || isempty(fig_size)
        fig_size = [800,600]; % px
    end
    if (nargin < 8) || isempty(gradient_cmap)
        gradient_cmap = [];
    end
    if (nargin < 9) || isempty(quiverArgs)
        quiverArgs = {};
    end
    if (nargin < 10) || isempty(pcolorArgs)
        pcolorArgs = {};
    end
    if (nargin < 11) || isempty(startArgs)
        startArgs = {};
    end
    if (nargin < 12) || isempty(targetArgs)
        targetArgs = {};
    end
    if (nargin < 13) || isempty(arenaArgs)
        arenaArgs = {};
    end
    if (nargin < 14) || isempty(showLattice)
        showLattice = true;
    end
    if (nargin < 15) || isempty(latticeArgs)
        latticeArgs = {};
    end
    if (nargin < 16) || isempty(showPreviousTarget)
        showPreviousTarget = false;
    end
    if (nargin < 17) || isempty(prevTargetArgs)
        prevTargetArgs = {};
    end
    if (nargin < 18) || isempty(showGradientMagnitude)
        showGradientMagnitude = true;
    end
    if (nargin < 19) || isempty(arena_outside_patch_args)
        arena_outside_patch_args = {};
    end
    if (nargin < 20) || isempty(mouse_step_prob_struct_jackknife)
        mouse_step_prob_struct_jackknife = {};
    end
    if (nargin < 21) || isempty(show_jk_avg)
        show_jk_avg = false;
    end
    if (nargin < 22) || isempty(calc_significant_path_args)
        calc_significant_path_args = {}; % refer to arena.calc_significant_path ; only used if mouse_step_prob_struct_jackknife not empty
    end
    if (nargin < 23) || isempty(use_color_quiver)
        use_color_quiver = false;
    end
    if (nargin < 24) || isempty(show_holes)
        show_holes = false;
    end
    if (nargin < 25) || isempty(holesArgs)
        holesArgs = {}; % 'Rotation',angle -> rotates holes coords by angle (CCW positive)
    end
    
    arenaArgs   = func.get_args_set_default(arenaArgs  ,'LineWidth',2  ,'EdgeColor','k','FaceColor','none');
    latticeArgs = func.get_args_set_default(latticeArgs,'LineWidth',0.1,'EdgeColor','w','FaceColor','none','EdgeAlpha',0.2);
    holesArgs   = func.get_args_set_default(holesArgs  ,'LineStyle','none','Marker','o','LineWidth',0.1,'Color',0.6.*ones(1,3),'MarkerFaceColor','none','MarkerSize',2);
    
    if iscell(mouse_step_prob_struct)
        if ~isempty(mouse_step_prob_struct_jackknife)
            if numel(mouse_step_prob_struct_jackknife) ~= numel(mouse_step_prob_struct)
                warning('plot_mouse_prob_gradient:mouse_step_prob_struct_jackknife','repeating mouse_step_prob_struct_jackknife for each entry in mouse_step_prob_struct');
                mouse_step_prob_struct_jackknife = func.repeatToComplete({mouse_step_prob_struct_jackknife},numel(mouse_step_prob_struct));
            end
        end
        if ~iscell(learning_stage_ind)
            learning_stage_ind = func.repeatToComplete({learning_stage_ind},numel(mouse_step_prob_struct));
        end
        if isempty(targetArgs) || (iscell(targetArgs) && (~iscell(targetArgs{1}))) || (~iscell(targetArgs)) 
            targetArgs = func.repeatToComplete({targetArgs},numel(mouse_step_prob_struct));
        end
        if iscell(targetArgs) && (iscell(targetArgs{1})) && ( numel(targetArgs) <  numel(mouse_step_prob_struct)  )
            targetArgs = func.repeatToComplete(targetArgs,numel(mouse_step_prob_struct));
        end
        
        n_panels = sum(cellfun(@numel,learning_stage_ind));
        nRows    = ceil(n_panels / nPanel_per_row);
        fig_pos  = [100,100,fig_size(:)'];
        fig      = figure('Position',fig_pos);
        ax = gobjects(0,0);
        G = cell(size(learning_stage_ind));
        panel_ind_start = 0;
        for i = 1:numel(mouse_step_prob_struct)
            [aax,G{i},panel_ind_start] = plot_mouse_prob_gradient_internal(mouse_step_prob_struct{i},learning_stage_ind{i},nPanel_per_row,mouse_idx,...
                                           use_grid_visits_as_color,force_cumulative_prob,fig_size,gradient_cmap,...
                                           quiverArgs,pcolorArgs,startArgs,targetArgs{i},arenaArgs,...
                                           showLattice,latticeArgs,...
                                           showPreviousTarget,prevTargetArgs,showGradientMagnitude,arena_outside_patch_args,false,nRows,fig,panel_ind_start,...
                                           mouse_step_prob_struct_jackknife{i},show_jk_avg,calc_significant_path_args,use_color_quiver,show_holes,holesArgs);
            ax((end+1):(end+numel(aax))) = aax;
        end
    else
        [ax,G] = plot_mouse_prob_gradient_internal(mouse_step_prob_struct,learning_stage_ind,nPanel_per_row,mouse_idx,...
                                       use_grid_visits_as_color,force_cumulative_prob,fig_size,gradient_cmap,...
                                       quiverArgs,pcolorArgs,startArgs,targetArgs,arenaArgs,...
                                       showLattice,latticeArgs,...
                                       showPreviousTarget,prevTargetArgs,showGradientMagnitude,arena_outside_patch_args,true,[],[],0,...
                                       mouse_step_prob_struct_jackknife,show_jk_avg,calc_significant_path_args,use_color_quiver,show_holes,holesArgs);
    end
end

function [ax,G,panel_ind_start] = plot_mouse_prob_gradient_internal(mouse_step_prob_struct,learning_stage_ind,nPanel_per_row,mouse_idx,...
                                       use_grid_visits_as_color,force_cumulative_prob,fig_size,gradient_cmap,...
                                       quiverArgs,pcolorArgs,startArgs,targetArgs,arenaArgs,...
                                       showLattice,latticeArgs,...
                                       showPreviousTarget,prevTargetArgs,showGradientMagnitude,arena_outside_patch_args,create_fig,nRows,fig,panel_ind_start,...
                                       mouse_step_prob_struct_jackknife,show_jk_avg,calc_significant_path_args,use_color_quiver,...
                                       show_holes,holesArgs)
    %assert(nPanel_per_row>2,'nPanel_per_row must be greater than 2');
    assert(isfield(mouse_step_prob_struct.learning_stage(1),'mouse'),'plot_prob_gradient :: mouse_step_prob_struct must be in the ''mouse'' struct format -- see import.import_mouse_stepmat');
    
    n_panels = numel(learning_stage_ind);
    if create_fig
        nRows    = ceil(n_panels / nPanel_per_row);
        fig_pos  = [100,100,fig_size(:)'];
        fig      = figure('Position',fig_pos);
    end
    ax       = gobjects(1,n_panels);
    G = cell(1,n_panels);
    ind      = learning_stage_ind;
    for i = 1:n_panels
        % creating axis
        figure(fig);
        ax(i) = subplot(nRows,nPanel_per_row,panel_ind_start+i);
        
        % calculating gradient
        sites_jackknife = [];
        if isnan(mouse_idx)
            sites_latt      = mouse_step_prob_struct.sites_per_stage{ind(i)};
            if ~isempty(mouse_step_prob_struct_jackknife)
                sites_jackknife = import.get_sites_for_learning_stage(mouse_step_prob_struct_jackknife,ind(i));
            end
        else
            sites_latt = mouse_step_prob_struct.learning_stage(ind(i)).mouse(mouse_idx).sites;
        end
        
        % plotting the probability gradient
        %                       (ax,   sites     ,simParam                       ,use_grid_visits_as_color,colorMap,quiverArgs,pcolorArgs)
        
        disp('plot_mouse_prob_gradient :: setting food_site as r_target_trial instead of general r_target');
        mouse_step_prob_struct.simParam.food_site = mouse_step_prob_struct.learning_stage(ind(i)).target;
        
        prevTargetArgsTemp                        = [prevTargetArgs,'LatticeSitePosition',mouse_step_prob_struct.learning_stage(ind(i)).target_prev];
        [~,~,food_start_ph,~,~,~,G{i}] = arena.plot_prob_gradient(ax(i),sites_latt,mouse_step_prob_struct.simParam,use_grid_visits_as_color,gradient_cmap,...
                                                                   quiverArgs,pcolorArgs,startArgs,targetArgs,showPreviousTarget,prevTargetArgsTemp,showGradientMagnitude,...
                                                                   sites_jackknife,show_jk_avg,calc_significant_path_args,...
                                                                   use_color_quiver);
        
        % plotting lattice grid
        if showLattice
            [latth,X,Y] = plot_func.plot_lattice_grid(ax(i),sites_latt,mouse_step_prob_struct.simParam,latticeArgs);
        end
        
        if show_holes
            hold(ax(i),'on');
            [rot_angle,holesArgs_c] = func.getParamValue('Rotation',holesArgs,true);
            r_holes                 = arena.get_arena_holes_in_lattice(mouse_step_prob_struct.simParam.L(1),rot_angle);
            holesh                  = plot(ax(i),r_holes(:,1),r_holes(:,2),holesArgs_c{:});
        end
        
        % plotting the arena circle
        [ax(i),rh] = plot_func.plot_arena_circle(ax(i),mouse_step_prob_struct.simParam,arenaArgs,arena_outside_patch_args);

        uistack(food_start_ph(1),'top');
        uistack(food_start_ph(2),'top');
        if numel(food_start_ph) > 2
            uistack(food_start_ph(3),'top');
        end
        
        % adjusting axis properties
        title(ax(i),sprintf('Trial %d',ind(i)),'FontWeight','normal');
        set(ax(i),'XLim',[0,mouse_step_prob_struct.simParam.L(1)+1],'YLim',[0,mouse_step_prob_struct.simParam.L(2)+1],'Box','off','Color','w');
    end
    panel_ind_start = panel_ind_start + n_panels;
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