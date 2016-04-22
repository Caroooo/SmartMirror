function do_output(results)

SHOW_AS_VIDEO = false;
SHOW_AS_IMAGE = false;
PRINT_PARAMS = true;

persistent videoPlayer;
global cam;

persistent lastToc;
if isempty(lastToc)
    lastToc = toc;
end

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

% Handle FPS calculations and display
currentToc = toc;
period = currentToc - lastToc;
fps = 1/period;
lastToc = currentToc;

person_name = results.person_name;
bps = results.bps;
bpd = results.bpd;
hb = results.hb;
rr = results.rr;

if PRINT_PARAMS
   print_info(person_name, hb, bps, bpd, rr, fps);
end