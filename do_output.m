function do_output(results)

SHOW_VIDEO = true;

persistent videoPlayer;
global cam;

if SHOW_VIDEO
    if isempty(videoPlayer)
        frameSize = sscanf(cam.Resolution, '%dx%d');
        videoPlayer = vision.VideoPlayer('Position',...
                        [100 100 [frameSize(1), frameSize(2)]+30]);
    end

    %step(videoPlayer, results);
    %imshow(results);
end