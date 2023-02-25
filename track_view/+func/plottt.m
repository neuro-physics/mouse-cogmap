clc
clear
close all

rootdir = 'C:\Users\fmora103\iCloudDrive\Desktop\Mauricio\Trajectories-main\mouse_track\experiments\preliminary\mouse_6';
files   = dir(fullfile(rootdir,['*.mat']));

for n=1:length(files)
    load([files(1).folder '\' files(n).name])
    files(n).name
    clf
    plot(r_arena_holes(:,1),r_arena_holes(:,2),'o')
    hold on
    plot(r_arena_center(:,1),r_arena_center(:,2),'x')
    hold on
    plot(r_target(:,1),r_target(:,2),'Ob',LineWidth=5)
    h = animatedline('Color','r');
    axis([-80 ...
        ,80,-80,80])
    for i=1:length(r_center)
        addpoints(h,r_center(i,1),r_center(i,2))
        axis square

        drawnow
    end
    pause
end






