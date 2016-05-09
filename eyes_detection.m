function eyes = eyes_detection(face)

% Setup
CRITICAL_POINT_NUM = 10;
SOFT_POINT_NUM = 60;
RECHECK_RATE = 30;
RESCALE_WIDTH = 200;
RESCALE_HEIGHT = 40;
RESCALE_METHOD = 'bilinear';

% Create the eyes detector object.
persistent eyesDetector;
if isempty(eyesDetector)
    eyesDetector = vision.CascadeObjectDetector('eyePairSmall');
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
faceGray = rgb2gray(face);
frameCount = frameCount + 1;


if numPts < CRITICAL_POINT_NUM
    % If not enough points, detect eyes again
    
    [success, numPts, oldPoints, bboxPoints] = ...
        detect(faceGray, eyesDetector, pointTracker);
    if success
        [face, myPoly] = draw_stuff(face, bboxPoints, oldPoints);
    end
else
    % If there are enough points, usually try just tracking
    do_tracking = 1;

    % Maybe check detection again if number of points
    % dropped below some soft cap
    if (mod(frameCount, RECHECK_RATE) == 0)&&(numPts < SOFT_POINT_NUM)
        [success, tnumPts, toldPoints, tbboxPoints] = ...
            detect(faceGray, eyesDetector, pointTracker);

        % If new detection is good, reset tracking
        if success && tnumPts > numPts
            do_tracking = 0;

            numPts = tnumPts;
            oldPoints = toldPoints;
            bboxPoints = tbboxPoints;

            [face, myPoly] = draw_stuff(face, bboxPoints, oldPoints);
        end
    end

    if do_tracking == 1
        % Track the eyes
        [visiblePoints, oldInliers, numPts] = ...
            track_object(pointTracker,faceGray, oldPoints);

        % If track successful, calculate/draw things
        if numPts >= 10

            [bboxPoints, visiblePoints] = ...
                find_transform(oldInliers, visiblePoints, bboxPoints);

            [face, myPoly] = draw_stuff(face, bboxPoints, visiblePoints);

            % Reset the points.
            oldPoints = visiblePoints;
            setPoints(pointTracker, oldPoints);
        end
    end
end

%imshow(face);
if myPoly ~= 0
    % If a eyes is found, pass it 
    xses = double(myPoly(1:2:end));
    yses = double(myPoly(2:2:end));
    
    % Crop and rotate image
    cropped_eyes = extract_poly(face, xses, yses, false);
    
    % Resize so it is always the same size
    eyes = imresize(cropped_eyes,...
                    [RESCALE_HEIGHT RESCALE_WIDTH],RESCALE_METHOD);
%     figure,imshow(eyes);
else
    % If not, pass a black image
    eyes = [];
end