function ax = animate_template_func(input_file_name,output_file_name)
% input_file_name  -> for example, the name of the .mat input file containing the trajectory
% output_file_name -> true, false, or the name of the output video file
%
% you function plott goes inside the record_frame function below

    mouse_track = load(input_file_name);

    % do we want to record the runs?
    video_fileName = output_file_name;
    recordVideo    = ~isempty(output_file_name);
    if recordVideo
        [vw,fh,ax] = setup_video(video_fileName,mouse_track); % you can add other input arguments to this function that you see need to help you plot
    else
        fh=figure;
        ax=axes;
        vw=[];
    end

    % main for loop where you draw the trajectory point by point
    % for example, the for loop you have made in plott.m
    plot_trajectory(fh,ax,mouse_track,recordVideo,vw);

    % any video to close?
    if recordVideo
        vw.close();
    end
end

function plot_trajectory(fh,ax,fileStruct,recordVideo,vw)
    plot(ax,fileStruct.r_arena_holes(:,1),fileStruct.r_arena_holes(:,2),'o')
    hold(ax,"on");
    plot(ax,fileStruct.r_arena_center(:,1),fileStruct.r_arena_center(:,2),'x')
    hold(ax,"on");
    plot(ax,fileStruct.r_target(:,1),fileStruct.r_target(:,2),'Ob',LineWidth=5)
    h = animatedline(ax,'Color','r');
    axis(ax,[-80,80,-80,80]);
    for i=1:length(fileStruct.r_center)
        addpoints(h,fileStruct.r_center(i,1),fileStruct.r_center(i,2))
        axis(ax,'square');

        drawnow

        if recordVideo
            % the record_frame below should be your plott function
            vw = record_frame(vw,fh,ax,mouse_track); % you can add other input arguments to this function that you see need to help you plot the axis for each step
        end
    end

    
end

function vw = record_frame(vw,fh,ax,mouse_track)
    % these parameters are just examples...
    % this function should contain you plott function
    % I kept all the statements below for the sake of the example
    food_patch_x = 5;
    food_patch_y = 5;
    sites.x=ones(11*11);
    simParam.L=11;
    nRun=1
    num_of_steps=100;
    imagesc(ax,reshape([sites.x],simParam.L));
    ax.NextPlot = 'add';
    ph = patch(ax,food_patch_x,food_patch_y,'w');
    ph.FaceColor = 'none';
    ph.EdgeColor = 'w';
    ax.NextPlot = 'replace';
    title(ax,['run ',num2str(nRun),', number of steps = ',num2str(num_of_steps)]);
    axis(ax,'square');
    daspect(ax,[1,1,1]);
    pause(0.01);

    % these are the important lines to save the video
    vframe = getframe(fh);
    vw.writeVideo(vframe);
end

function [vw,fh,ax] = setup_video(fileName,mouse_track)
    
    % I kept all the statements below for the sake of the example

    simParam=struct('L',11,'food_site',5+4*11);

    vid_id = num2str(rand,'%.16g');
    vid_id = vid_id(3:6);
    if ischar(fileName)
        fileName = [fileName,'_',vid_id,'.mp4'];
    else
        fileName = ['mouse_run_',vid_id,'.mp4']
    end
    fh = figure;
    ax=axes;

    % Initialize video
    vw = VideoWriter(fileName, 'MPEG-4'); %open video file
    vw.Quality = 100;
    vw.FrameRate = 16;
    vw.open();

    % initialize plotting axis

    [food_patch_y,food_patch_x] = ind2sub(simParam.L,simParam.food_site);
    food_patch_x = [food_patch_x-0.5,food_patch_x+0.5,food_patch_x+0.5,food_patch_x-0.5];
    food_patch_y = [food_patch_y-0.5,food_patch_y-0.5,food_patch_y+0.5,food_patch_y+0.5];

    imagesc(ax,zeros(simParam.L));
    hold(ax,'on');
    ph = patch(ax,food_patch_x,food_patch_y,'w');
    ph.FaceColor = 'none';
    ph.EdgeColor = 'w';
    axis(ax,'square');
    daspect(ax,[1,1,1]);
end