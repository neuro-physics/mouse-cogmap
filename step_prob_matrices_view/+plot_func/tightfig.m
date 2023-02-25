function hfig = tightfig(hfig)
% tightfig: Alters a figure so that it has the minimum size necessary to
% enclose all axes in the figure without excess space around them.
% 
% Note that tightfig will expand the figure to completely encompass all
% axes if necessary. If any 3D axes are present which have been zoomed,
% tightfig will produce an error, as these cannot easily be dealt with.
% 
% hfig - handle to figure, if not supplied, the current figure will be used
% instead.

    if nargin == 0
        hfig = gcf;
    end

    % There can be an issue with tightfig when the user has been modifying
    % the contnts manually, the code below is an attempt to resolve this,
    % but it has not yet been satisfactorily fixed
%     origwindowstyle = get(hfig, 'WindowStyle');
    set(hfig, 'WindowStyle', 'normal');
    
    % 1 point is 0.3528 mm for future use

    % get all the axes handles note this will also fetch legends and
    % colorbars as well
    hax = findall(hfig, 'type', 'axes');
    [origaxunits_ax,figwidth,figheight,moveleft,movedown] = tight_ax(hax);
    
    hcb = findall(hfig, 'type', 'colorbar');
    %ind_cb = arrayfun(@(x)contains(class(x),'colorbar','IgnoreCase',true),hfig.Children);
    if ~isempty(hcb)
        [origaxunits_cb,cb_new_pos] = tight_cb(hcb,moveleft,movedown);
    end
    
    %function reposition_colorbar(~,~,c)        
    %    for i = 1:numel(c)
    %        set(c(i), 'Position', cb_new_pos{i});
    %    end
    %end
    %set(hfig,'ResizeFcn',{@reposition_colorbar hcb});
    
    %pause(1)
    %drawnow
    
    origfigunits = get(hfig, 'Units');
    
    set(hfig, 'Units', 'centimeters');
    
    % change the size of the figure
    figpos = get(hfig, 'Position');
    
    waitfor(hfig,'Units','centimeters');
    waitfor(hcb ,'Units','centimeters');
    %disp(hfig.Children(ind_cb));
    %drawnow
    
    set(hfig, 'Position', [figpos(1), figpos(2), figwidth, figheight]);
    
    % change the size of the paper
    set(hfig, 'PaperUnits'       , 'centimeters');
    set(hfig, 'PaperSize'        , [figwidth, figheight]);
    set(hfig, 'PaperPositionMode', 'manual');
    set(hfig, 'PaperPosition'    , [0 0 figwidth figheight]);    
    
    restore_ax_units(hax,origaxunits_ax);
    if ~isempty(hcb)
        restore_ax_units(hcb,origaxunits_cb);
    end

    set(hfig, 'Units', origfigunits);
    
%      set(hfig, 'WindowStyle', origwindowstyle);
end

function restore_ax_units(hax,origaxunits)
    % reset to original units for axes and figure 
    if ~iscell(origaxunits)
        origaxunits = {origaxunits};
    end

    for i = 1:numel(hax)
        set(hax(i), 'Units', origaxunits{i});
    end
end

function [origaxunits,new_pos] = tight_cb(hax,moveleft,movedown)
    % get the original axes units, so we can change and reset these again
    % later
    origaxunits = get(hax, 'Units');
    
    % change the axes units to cm
    set(hax, 'Units', 'centimeters');
    waitfor(hax,'Units','centimeters');
    
    % get various position parameters of the axes
    if numel(hax) > 1
%         fsize = cell2mat(get(hax, 'FontSize'));
        pos = cell2mat(get(hax, 'Position'));
    else
%         fsize = get(hax, 'FontSize');
        pos = get(hax, 'Position');
    end
    
    % move all the axes
    new_pos = cell(size(hax));
    for i = 1:numel(hax)
        new_pos{i} = get_new_ax_position(pos(i,:),moveleft,movedown);
        set(hax(i), 'Position', new_pos{i});
    end
     
end

function [origaxunits,figwidth,figheight,moveleft,movedown] = tight_ax(hax)
    % get the original axes units, so we can change and reset these again
    % later
    origaxunits = get(hax, 'Units');
    
    % change the axes units to cm
    set(hax, 'Units', 'centimeters');
    waitfor(hax,'Units','centimeters');
    
    % get various position parameters of the axes
    if numel(hax) > 1
%         fsize = cell2mat(get(hax, 'FontSize'));
        ti = cell2mat(get(hax,'TightInset'));
        pos = cell2mat(get(hax, 'Position'));
    else
%         fsize = get(hax, 'FontSize');
        ti = get(hax,'TightInset');
        pos = get(hax, 'Position');
    end
    
    % ensure very tiny border so outer box always appears
    ti(ti < 0.1) = 0.15;
    
    % we will check if any 3d axes are zoomed, to do this we will check if
    % they are not being viewed in any of the 2d directions
    views2d = [0,90; 0,0; 90,0];
    
    for i = 1:numel(hax)
        
        set(hax(i), 'LooseInset', ti(i,:));
%         set(hax(i), 'LooseInset', [0,0,0,0]);
        
        % get the current viewing angle of the axes
        [az,el] = view(hax(i));
        
        % determine if the axes are zoomed
        iszoomed = strcmp(get(hax(i), 'CameraViewAngleMode'), 'manual');
        
        % test if we are viewing in 2d mode or a 3d view
        is2d = all(bsxfun(@eq, [az,el], views2d), 2);
               
        if iszoomed && ~any(is2d)
           error('TIGHTFIG:haszoomed3d', 'Cannot make figures containing zoomed 3D axes tight.') 
        end
        
    end
    
    % we will move all the axes down and to the left by the amount
    % necessary to just show the bottom and leftmost axes and labels etc.
    moveleft = min(pos(:,1) - ti(:,1));
    
    movedown = min(pos(:,2) - ti(:,2));
    
    % we will also alter the height and width of the figure to just
    % encompass the topmost and rightmost axes and lables
    figwidth = max(pos(:,1) + pos(:,3) + ti(:,3) - moveleft);
    
    figheight = max(pos(:,2) + pos(:,4) + ti(:,4) - movedown);
    
    % move all the axes
    for i = 1:numel(hax)
        set(hax(i), 'Position', get_new_ax_position(pos(i,:),moveleft,movedown));
    end
     
end

function p = get_new_ax_position(p,moveleft,movedown)
    p = [p(1:2) - [moveleft,movedown], p(3:4)];
end