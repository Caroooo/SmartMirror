function do_output(results)

SHOW_AS_VIDEO = false;
SHOW_AS_IMAGE = true;

persistent videoPlayer;
global cam;

if SHOW_AS_VIDEO
    if isempty(videoPlayer)
        frameSize = sscanf(cam.Resolution, '%dx%d');
        videoPlayer = vision.VideoPlayer('Position',...
                        [100 100 [frameSize(1), frameSize(2)]+30]);
    end

    step(videoPlayer, results);
end

if SHOW_AS_IMAGE
    imshow(results);
end