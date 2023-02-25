function f = makeVideo(axh, vname, outFormat)
    f = repmat(struct('cdata',[],'colormap',[]),1,numel(axh));
    for i = 1:numel(axh)
        f(i) = getframe(axh(i));
    end
    if strcmpi(outFormat, 'mp4')
        vw = VideoWriter(vname, 'MPEG-4');
        %vw = VideoWriter(vname, 'Motion JPEG 2000');
        vw.Quality = 100;
        vw.FrameRate = 2;
        %vw.CompressionRatio = 1;
        %vw.VideoCompressionMethod = 'None';
        vw.open();
        for i = 1:numel(f)
            vw.writeVideo(f(i));
        end
        vw.close();
    elseif strcmpi(outFormat, 'gif')
        img = frame2im(f(1));
        [imgK,cm] = rgb2ind(img,256);
        imwrite(imgK, cm, vname, 'gif', 'Loopcount', Inf);
        for i = 2:numel(f)
            img = frame2im(f(i));
            [imgK,cm] = rgb2ind(img,256);
            imwrite(imgK, cm, vname, 'gif', 'WriteMode', 'append');
        end
    else
        error('makeVideo:outFormat','unrecognized output format');
    end
end
