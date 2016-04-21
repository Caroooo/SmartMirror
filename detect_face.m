function [success, numPts, oldPoints, bboxPoints] = detect_face(videoFrameGray, faceDetector, pointTracker)
% Detection mode.
bbox = faceDetector.step(videoFrameGray);

numPts = 0;
oldPoints = 0;
bboxPoints = 0;

success = ~isempty(bbox);

if success
    % Find corner points inside the detected region.
    %detectBRISKFeatures
    points = detectMinEigenFeatures(videoFrameGray, 'ROI', bbox(1, :));

    if ~isempty(points)
        % Re-initialize the point tracker.
        xyPoints = points.Location;
        numPts = size(xyPoints,1);
        release(pointTracker);
        initialize(pointTracker, xyPoints, videoFrameGray);

        % Save a copy of the points.
        oldPoints = xyPoints;

        % Convert the rectangle represented as [x, y, w, h] into an
        % M-by-2 matrix of [x,y] coordinates of the four corners. This
        % is needed to be able to transform the bounding box to display
        % the orientation of the face.
        bboxPoints = bbox2points(bbox(1, :));
    end 
end