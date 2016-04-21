function [bboxPoints, visiblePoints] = find_transform(oldInliers, visiblePoints, bboxPoints)
% Estimate the geometric transformation between the old points
% and the new points.
[xform, oldInliers, visiblePoints] = estimateGeometricTransform(...
    oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);

% Apply the transformation to the bounding box.
bboxPoints = transformPointsForward(xform, bboxPoints);