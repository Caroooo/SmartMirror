function image_to_show = face_detection(image)

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

my_poly = 0;
videoFrame = image;
videoFrameGray = rgb2gray(videoFrame);
frameCount = frameCount + 1;

% If not enough points, detect face again
if numPts < CRITICAL_POINT_NUM
    [success, numPts, oldPoints, bboxPoints] = ...
        detect_face(videoFrameGray, faceDetector, pointTracker);
    if success
        [videoFrame, my_poly] = draw_stuff(videoFrame, bboxPoints, oldPoints);
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

            [videoFrame, my_poly] = draw_stuff(videoFrame, bboxPoints, oldPoints);
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

            [videoFrame, my_poly] = draw_stuff(videoFrame, bboxPoints, visiblePoints);

            % Reset the points.
            oldPoints = visiblePoints;
            setPoints(pointTracker, oldPoints);
        end
    end
end

xses = double(my_poly(1:2:end))
yses = double(my_poly(2:2:end))
mask = poly2mask(xses, yses, size(videoFrame,1), size(videoFrame,2));
image_to_show = videoFrameGray .* uint8(mask);
imshow(image_to_show,[]);
