close all;
cam = webcam(1);
video = get_video(5, cam);
clear('cam');

correct = 0;
fail = 0;
for i = 1 : size(video,4)

    % Create a cascade detector object.
    faceDetector = vision.CascadeObjectDetector();
    
    % Read a video frame and run the detector.
    videoFrame      = video(:,:,:,i);
    bbox            = step(faceDetector, videoFrame);
    
    if isempty(bbox) || size(bbox, 1) ~= 1
        fail = fail + 1;
        continue;
    end
    
    detectedFace = videoFrame(bbox(2):bbox(2) + bbox(4),bbox(1):bbox(1)...
             + bbox(3),:);
        imshow(detectedFace)
    correct = correct + 1;

end

fprintf('correct: %d\nfail:    %d\n',correct,fail)
% % Detect feature points in the face region.
% points = detectMinEigenFeatures(rgb2gray(videoFrame), 'ROI', bbox);
% 
% % Display the detected points.
% figure, imshow(videoFrame), hold on, title('Detected features');
% plot(points);
% 
% % Create a point tracker and enable the bidirectional error constraint to
% % make it more robust in the presence of noise and clutter.
% pointTracker = vision.PointTracker('MaxBidirectionalError', 2);
% 
% % Initialize the tracker with the initial point locations and the initial
% % video frame.
% points = points.Location;
% initialize(pointTracker, points, videoFrame);
% 
% videoPlayer  = vision.VideoPlayer('Position',...
%     [100 100 [size(videoFrame, 2), size(videoFrame, 1)]+30]);
% 
% % Make a copy of the points to be used for computing the geometric
% % transformation between the points in the previous and the current frames
% oldPoints = points;
% 
% while ~isDone(videoFileReader)
%     % get the next frame
%     videoFrame = step(videoFileReader);
% 
%     % Track the points. Note that some points may be lost.
%     [points, isFound] = step(pointTracker, videoFrame);
%     visiblePoints = points(isFound, :);
%     oldInliers = oldPoints(isFound, :);
% 
%     if size(visiblePoints, 1) >= 2 % need at least 2 points
% 
%         % Estimate the geometric transformation between the old points
%         % and the new points and eliminate outliers
%         [xform, oldInliers, visiblePoints] = estimateGeometricTransform(...
%             oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);
% 
%         % Apply the transformation to the bounding box points
%         bboxPoints = transformPointsForward(xform, bboxPoints);
% 
%         % Insert a bounding box around the object being tracked
%         bboxPolygon = reshape(bboxPoints', 1, []);
%         videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, ...
%             'LineWidth', 2);
% 
%         % Display tracked points
%         videoFrame = insertMarker(videoFrame, visiblePoints, '+', ...
%             'Color', 'white');
% 
%         % Reset the points
%         oldPoints = visiblePoints;
%         setPoints(pointTracker, oldPoints);
%     end
% 
%     % Display the annotated video frame using the video player object
%     step(videoPlayer, videoFrame);
% end
% 
% % Clean up
% release(videoFileReader);
% release(videoPlayer);
% release(pointTracker);