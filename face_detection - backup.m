function face_detection(image)

%setup
CRITICAL_POINT_NUM = 10;
SOFT_POINT_NUM = 60;
RECHECK_RATE = 30;

% Create the face detector object.
persistent faceDetector;

if isempty(faceDetector)
    faceDetector = vision.CascadeObjectDetector();
end

% Create the point tracker object.
persistent pointTracker;

if isempty(pointTracker)
    pointTracker = vision.PointTracker('MaxBidirectionalError', 2);
end


% Capture one frame to get its size.
videoFrame = image;
frameSize = size(videoFrame);

% Create the video player object.
videoPlayer = vision.VideoPlayer('Position',...
                [100 100 [frameSize(2), frameSize(1)]+30]);

%runnung

runLoop = true;
numPts = 0;
frameCount = 0;

while runLoop

    % Get the next frame.
    videoFrame = snapshot(cam);
    videoFrameGray = rgb2gray(videoFrame);
    frameCount = frameCount + 1;

    % If not enough points, detect face again
    if numPts < CRITICAL_POINT_NUM
        [success, numPts, oldPoints, bboxPoints] = ...
            detect_face(videoFrameGray, faceDetector, pointTracker);
        if success
            videoFrame = draw_stuff(videoFrame, bboxPoints, xyPoints);
        end
        
    else
        do_tracking = 1;
        
        % Maybe check detection again
        if (mod(frameCount, RECHECK_RATE) == 0)&&(numPts < SOFT_POINT_NUM)
            [success, tnumPts, toldPoints, tbboxPoints] = ...
                detect_face(videoFrameGray, faceDetector, pointTracker);

            % If detection is good, reset tracking
            if success && tnumPts > numPts
                do_tracking = 0;
                
                numPts = tnumPts;
                oldPoints = toldPoints;
                bboxPoints = tbboxPoints;
                
                videoFrame = draw_stuff(videoFrame, bboxPoints, xyPoints);
            end
        end
        
        if do_tracking == 1
            % Track the face
            [visiblePoints, oldInliers, numPts] = ...
                track_face(pointTracker,videoFrameGray, oldPoints);

            % If track successful, calculate/draw things
            if numPts >= 10

                [bboxPoints, visiblePoints] = ...
                    find_transform(oldInliers, visiblePoints, bboxPoints);

                videoFrame = draw_stuff(videoFrame, bboxPoints, visiblePoints);

                % Reset the points.
                oldPoints = visiblePoints;
                setPoints(pointTracker, oldPoints);
            end
        end
    end

    faceImage = crop_face(videoFrame);
    call_modules(faceImage);
    
    % Display the annotated video frame using the video player object.
    step(videoPlayer, videoFrame);

    % Check whether the video player window has been closed.
    runLoop = isOpen(videoPlayer);
end

% Clean up.
clear cam;
release(videoPlayer);
release(pointTracker);
release(faceDetector);