function face = face_detection(image)

% Setup
CRITICAL_POINT_NUM = 10;
SOFT_POINT_NUM = 60;
RECHECK_RATE = 30;
RESCALE_SIZE = 300;
RESCALE_METHOD = 'bilinear';

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

persistent numPts;
if isempty(numPts)
    numPts = 0;
end

persistent frameCount;
if isempty(frameCount)
    frameCount = 0;
end

persistent oldPoints;
if isempty(oldPoints)
    oldPoints = 0;
end

persistent bboxPoints;
if isempty(bboxPoints)
    bboxPoints = 0;
end

myPoly = 0;
videoFrame = image;
videoFrameGray = rgb2gray(videoFrame);
frameCount = frameCount + 1;


if numPts < CRITICAL_POINT_NUM
    % If not enough points, detect face again
    
    [success, numPts, oldPoints, bboxPoints] = ...
        detect(videoFrameGray, faceDetector, pointTracker);
    if success
        [videoFrame, myPoly] = draw_stuff(videoFrame, bboxPoints, oldPoints);
    end

else
    % If there are enough points, usually try just tracking
    do_tracking = 1;

    % Maybe check detection again if number of points
    % dropped below some soft cap
    if (mod(frameCount, RECHECK_RATE) == 0)&&(numPts < SOFT_POINT_NUM)
        [success, tnumPts, toldPoints, tbboxPoints] = ...
            detect(videoFrameGray, faceDetector, pointTracker);

        % If new detection is good, reset tracking
        if success && tnumPts > numPts
            do_tracking = 0;

            numPts = tnumPts;
            oldPoints = toldPoints;
            bboxPoints = tbboxPoints;

            [videoFrame, myPoly] = draw_stuff(videoFrame, bboxPoints, oldPoints);
        end
    end

    if do_tracking == 1
        % Track the face
        [visiblePoints, oldInliers, numPts] = ...
            track_object(pointTracker,videoFrameGray, oldPoints);

        % If track successful, calculate/draw things
        if numPts >= 10

            [bboxPoints, visiblePoints] = ...
                find_transform(oldInliers, visiblePoints, bboxPoints);

            [videoFrame, myPoly] = draw_stuff(videoFrame, bboxPoints, visiblePoints);

            % Reset the points.
            oldPoints = visiblePoints;
            setPoints(pointTracker, oldPoints);
        end
    end
end


if myPoly ~= 0
    % If a face is found, pass it 
    xses = double(myPoly(1:2:end));
    yses = double(myPoly(2:2:end));
    
    % Crop and rotate image
    cropped_face = extract_poly(videoFrame, xses, yses, true);
    
    % Resize so it is always the same size
    face = imresize(cropped_face,...
                    [RESCALE_SIZE RESCALE_SIZE],RESCALE_METHOD);
else
    % If not, pass a black image
    face = [];
end

