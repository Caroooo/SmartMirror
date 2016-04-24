function do_output(results)

global NO_DETECTION NO_REFRESH REFRESH SYSTEM_START;

% SHOW_AS_VIDEO = false;
% SHOW_AS_IMAGE = false;
PRINT_PARAMS = true;

persistent videoPlayer;
global cam;

persistent lastToc;
if isempty(lastToc)
    lastToc = toc;
end

persistent lastState;
if isempty(lastState)
    lastState = SYSTEM_START;
end

% if SHOW_AS_VIDEO
%     if isempty(videoPlayer)
%         frameSize = sscanf(cam.Resolution, '%dx%d');
%         videoPlayer = vision.VideoPlayer('Position',...
%                         [100 100 [frameSize(1), frameSize(2)]+30]);
%     end
% 
%     step(videoPlayer, results);
% end
% 
% if SHOW_AS_IMAGE
%     imshow(results);
% end

% Handle FPS calculations and display
currentToc = toc;
period = currentToc - lastToc;
fps = 1/period;
lastToc = currentToc;


% If there is no face found, print that information and no phys params
if results.state == NO_DETECTION
    if PRINT_PARAMS
        
        % Don't reprint like mad if the system doesn't see faces
        if lastState ~= NO_DETECTION
            print_info(results.person_name, results.hb, results.bp,...
                        results.rr, fps);
        end
    end
    
% If there is face, update info only if refresh period has passed
elseif results.state == REFRESH
    if PRINT_PARAMS
        print_info(results.person_name, results.hb, results.bp,...
                    results.rr, fps);
    end
end

lastState = results.state;