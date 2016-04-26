function [visiblePoints, oldInliers, numPts] = track_object(pointTracker, videoFrameGray, oldPoints)

% Tracking mode.
[xyPoints, isFound] = step(pointTracker, videoFrameGray);
visiblePoints = xyPoints(isFound, :);
oldInliers = oldPoints(isFound, :);

numPts = size(visiblePoints, 1);