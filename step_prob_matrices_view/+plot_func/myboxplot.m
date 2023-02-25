function [h,lh,sh] = myboxplot(ax,data_cell,x_pos,significance_matrix,labels,colors,box_alpha,box_width,label_angle,show_caps,show_outliers,data_avg_symbol,whiskerArgs,medianArgs,avgArgs,significanceArgs)
    if isempty(ax)
        ax = gca;
    end
    if (nargin < 3) || isempty(x_pos)
        x_pos = 1:numel(data_cell);
    end
    if (nargin < 4) || isempty(significance_matrix)
        significance_matrix = [];
    end
    if (nargin < 5) || isempty(labels)
        labels = {};
    end
    if (nargin < 6) || isempty(colors)
        colors = [];
    end
    if (nargin < 7) || isempty(box_alpha)
        box_alpha = 1;
    end
    if (nargin < 8) || isempty(box_width)
        box_width = 0.5;
    end
    if (nargin < 9) || isempty(label_angle)
        label_angle = 0;
    end
    if (nargin < 10) || isempty(show_caps)
        show_caps = false;
    end
    if (nargin < 11) || isempty(show_outliers)
        show_outliers = false;
    end
    if (nargin < 12) || isempty(data_avg_symbol)
        data_avg_symbol = 'D';
    end
    if (nargin < 13) || isempty(whiskerArgs)
        whiskerArgs = {};
    end
    if (nargin < 14) || isempty(medianArgs)
        medianArgs = {};
    end
    if (nargin < 15) || isempty(avgArgs)
        avgArgs = {};
    end
    if (nargin < 16) || isempty(significanceArgs)
        significanceArgs = {};
    end
    
    whiskerArgs      = func.get_args_set_default(whiskerArgs     ,'LineStyle','-');
    medianArgs       = func.get_args_set_default(medianArgs      ,'LineStyle','-','LineWidth',2);
    avgArgs          = func.get_args_set_default(avgArgs         ,'Marker',data_avg_symbol,'MarkerSize',5);
    significanceArgs = func.get_args_set_default(significanceArgs,'SymbolArgs'   ,{'HandleVisibility','off','MarkerSize',5},...
                                                                  'LineArgs'     ,{'LineStyle','-','LineWidth',1.5,'HandleVisibility','off'},...
                                                                  'dy_y_level'   , 5, ...
                                                                  'capSize'      ,-6, ...
                                                                  'y_symbol_mult',1.5,...
                                                                  'label'        ,'',...
                                                                  'symbol'       ,'p',...
                                                                  'labelArgs'    ,{});
    
    
    [data,data_group] = plot_func.boxplot_prepare_data(data_cell);
    
    % the h rows are (plotstyle=='traditional' or boxstyle=='outline')
    %    h(1,:) -> upper whisker
    %    h(2,:) -> lower whisker
    %    h(3,:) -> upper adjacent value
    %    h(4,:) -> lower adjacent value
    %    h(5,:) -> box
    %    h(6,:) -> median
    %    h(7,:) -> outliers
    
    % the h rows are (plotstyle=='compact' or boxstyle=='filled')
    %    h(1,:) -> upper whisker
    %    h(2,:) -> box
    %    h(3,:) -> median
    %    h(4,:) -> outliers
    
    get_box_ind      = @(hh) find( strcmpi(arrayfun(@(x)x.Tag,hh(:,1),'UniformOutput',false),'Box'     ),1,'first');
    get_median_ind   = @(hh) find( strcmpi(arrayfun(@(x)x.Tag,hh(:,1),'UniformOutput',false),'Median'  ),1,'first');
    get_outlier_ind  = @(hh) find( strcmpi(arrayfun(@(x)x.Tag,hh(:,1),'UniformOutput',false),'Outliers'),1,'first');
    get_whisker_ind  = @(hh) find(contains(arrayfun(@(x)x.Tag,hh(:,1),'UniformOutput',false),'Whisker' ));
    get_caps_ind     = @(hh) find(contains(arrayfun(@(x)x.Tag,hh(:,1),'UniformOutput',false),'Adjacent'));
    
    h                = plot_func.boxplot_get_handles(boxplot(data,data_group,'Colors',colors,'Widths',box_width,'BoxStyle','outline'));
    if ~isempty(data_avg_symbol)
        h(end+1,:) = gobjects(1,size(h,2));
        k_avg      = size(h,1);
        for j = 1:size(h,2)
            lh         = line(ax,x_pos(j),nanmean(data_cell{j}),'Color',get_color(colors,j),avgArgs{:});
            h(k_avg,j) = lh;
        end
    end
    
    % getting row indices in h
    k_box     = get_box_ind(h);
    k_whisker = get_whisker_ind(h);
    k_median  = get_median_ind(h);
    k_outl    = get_outlier_ind(h);
    k_caps    = get_caps_ind(h);

    if box_alpha > 0
        hold(ax,'on');
        for j = 1:size(h,2)
            ph = patch(ax,h(k_box,j).XData,h(k_box,j).YData,get_color(colors,j),'EdgeColor',get_color(colors,j),'FaceAlpha',box_alpha,'HandleVisibility','off');
            ph.Tag = 'Box';
            uistack(ph,'bottom');
            delete(h(k_box,j));
            h(k_box,j) = ph;
            %ph = patch(ax,X',Y',faceC,'EdgeColor','none','HandleVisibility', 'off');
        end
    % setting box alpha
    %for j = 1:size(h,2)
    %    h(k_box,j).Color = [ h(k_box,j).Color, box_alpha ];
    %end
    end
    
    % adjusting labels
    if ~isempty(labels)
        ax.XTick              = x_pos;
        ax.XTickLabel         = labels;
        ax.XTickLabelRotation = label_angle;
    end
    
    set(h(k_median ,:), medianArgs{:});
    set(h(k_whisker,:),whiskerArgs{:});
    
    % deleting upper and lower adjacent values if needed
    if ~show_caps
        delete(h(k_caps,:));
    end
    
    % deleting outliers if needed
    if ~show_outliers
        delete(h(k_outl,:));
    end
    
    lh=gobjects(0,1);
    sh=gobjects(0,1);
    if ~isempty(significance_matrix)
        
        lh         = gobjects(size(significance_matrix));
        sh         = gobjects(size(significance_matrix));
        mm         = max(data(~isnan(data)));
        
        [ symbolArgs0   , significanceArgs ] = func.getParamValue('SymbolArgs'    , significanceArgs,true);
        [ lineArgs0     , significanceArgs ] = func.getParamValue('LineArgs'      , significanceArgs,true);
        [ dy_y_level    , significanceArgs ] = func.getParamValue('dy_y_level'    , significanceArgs,true);
        [ capSize       , significanceArgs ] = func.getParamValue('capSize'       , significanceArgs,true);
        [ y_symbol_mult , significanceArgs ] = func.getParamValue('y_symbol_mult' , significanceArgs,true);
        [ label         , significanceArgs ] = func.getParamValue('label'         , significanceArgs,true);
        [ symbol        , significanceArgs ] = func.getParamValue('symbol'        , significanceArgs,true);
        [ labelArgs     , significanceArgs ] = func.getParamValue('labelArgs'     , significanceArgs,true);
        for i = 1:size(significance_matrix,1)
            for j = 1:size(significance_matrix,2)
                if significance_matrix(i,j)
                    symbolArgs = func.get_args_set_default(symbolArgs0,'Color',get_color(colors,j),'MarkerFaceColor',get_color(colors,j));
                    lineArgs   = func.get_args_set_default(lineArgs0  ,'Color',get_color(colors,j));
                    [lh(i,j),sh(i,j),mm] = plot_func.annotate_ttest_data(ax,    x_pos(i),      x_pos(j),     mm+dy_y_level, capSize, y_symbol_mult, label, symbol, labelArgs, symbolArgs, lineArgs);
                end
            end
        end
    end
    
    h(~isvalid(h(:,1)),:)=[];
end

function c = get_color(cMap,k)
    c = cMap(mod(k-1,size(cMap,1))+1,:);
end