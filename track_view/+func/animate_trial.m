function ax = animate_trial(input_file_name,output_file_name,Tmax,show_target,show_holes,arena_bg_color,real_time,hole_check_data,fig_prop)
% input_file_name  -> for example, the name of the .mat input file containing the trajectory
% output_file_name -> true, false, or the name of the output video file
% Tmax             -> max time to show (in seconds)
%
%
% you function plott goes inside the record_frame function below

    if (nargin < 3) || isempty(Tmax)
        Tmax = NaN;
    end
    if (nargin < 4) || isempty(show_target)
        show_target = true;
    end
    if (nargin < 5) || isempty(show_holes)
        show_holes = true;
    end
    if (nargin < 6) || isempty(arena_bg_color)
        arena_bg_color = 'w';
    end
    if (nargin < 7) || isempty(real_time)
        real_time = false;
    end
    if (nargin < 8) || isempty(hole_check_data)
        hole_check_data = [];
    end
    if (nargin < 9) || isempty(fig_prop)
        fig_prop = {};
    end
    fig_prop = func.get_cell_set_default(fig_prop,'Position',[10,10,500,500]);
    

    mouse_track = load(input_file_name);

    % do we want to record the runs?
    video_fileName = output_file_name;
    recordVideo    = ~isempty(output_file_name);
    if recordVideo
        [vw,fh,ax] = setup_video(video_fileName,fig_prop); % you can add other input arguments to this function that you see need to help you plot
    else
        fh = figure(fig_prop{:});
        ax = axes;
        vw = [];
    end

    % main for loop where you draw the trajectory point by point
    % for example, the for loop you have made in plott.m
    plot_trajectory(fh,ax,mouse_track,recordVideo,vw,Tmax,show_target,show_holes,arena_bg_color,hole_check_data,real_time);

    % any video to close?
    if recordVideo
        vw.close();
    end
end

function plot_trajectory(fh,ax,fileStruct,recordVideo,vw,Tmax,show_target,show_holes,arena_bg_color,hole_check_data,real_time)
    axis(ax,'off');
    axis(ax,'equal');
    axis(ax,'square');
    daspect(ax,[1,1,1]);
    func.plot_arena_circle(ax,fileStruct,{'LineWidth',2,'FaceColor',arena_bg_color,'EdgeColor','k'});
    hold(ax,"on");
    if show_holes
        plot(ax,fileStruct.r_arena_holes(:,1),fileStruct.r_arena_holes(:,2),'o','Color',0.5.*ones(1,3),'MarkerSize',3);
    end
    plot(ax,fileStruct.r_start(1),fileStruct.r_start(2),'sk','LineWidth',2,'MarkerSize',10);
    %plot(ax,fileStruct.r_arena_center(:,1),fileStruct.r_arena_center(:,2),'x')
    if show_target
        plot(ax,fileStruct.r_target(:,1),fileStruct.r_target(:,2),'Ob','LineWidth',5)
    end
    h = animatedline(ax,'Color','b','LineWidth',2);
    arena_rad = fileStruct.arena_diameter/2;
    axis(ax,[-arena_rad-2,arena_rad+2,-arena_rad-2,arena_rad+2]);
    dt = diff(fileStruct.time(:)');
    dt(end+1)=dt(end);
    k = 1;
    tic;
    for i=1:numel(fileStruct.time)
        addpoints(h,fileStruct.r_nose(i,1),fileStruct.r_nose(i,2))

        if ~isempty(hole_check_data)
            if i == hole_check_data.k_slow(k)
                plot(ax,hole_check_data.r_slow(k,1),hole_check_data.r_slow(k,2),'or','LineWidth',2,'MarkerFaceColor','none','MarkerSize',10);
                k = k + 1;
            end
        end
        
        drawnow
        if real_time
            tdiff = toc;
            pause(dt(i)-tdiff);
            tic;
        end

        if recordVideo
            % the record_frame below should be your plott function
            vw = record_frame(vw,fh); % you can add other input arguments to this function that you see need to help you plot the axis for each step
        end
        if ~isnan(Tmax)
            if fileStruct.time(i)>Tmax
                break;
            end
        end
    end

    
end

function vw = record_frame(vw,fh)
    % these are the important lines to save the video
    vframe = getframe(fh);
    vw.writeVideo(vframe);
end

function [vw,fh,ax] = setup_video(fileName,fig_prop)
    vid_id = num2str(rand,'%.16g');
    vid_id = vid_id(3:6);
    if ischar(fileName)
        fileName = [fileName,'_',vid_id,'.mp4'];
    else
        fileName = ['mouse_run_',vid_id,'.mp4'];
    end
    fh = figure(fig_prop{:});
    ax = axes;

    % Initialize video
    vw = VideoWriter(fileName, 'MPEG-4'); %open video file
    vw.Quality = 100;
    vw.FrameRate = 16;
    vw.open();
end