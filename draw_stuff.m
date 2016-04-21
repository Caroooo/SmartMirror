function [videoFrame, bboxPolygon] = draw_stuff(videoFrame, bboxPoints, pointsToDraw)

% Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
% format required by insertShape.
bboxPolygon = reshape(bboxPoints', 1, []);

% Display a bounding box around the face being tracked.
videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, 'LineWidth', 3);

% Display tracked points.
videoFrame = insertMarker(videoFrame, pointsToDraw, '*', 'Color', 'white');

videoFrame = insertText(videoFrame, [0,0], size(pointsToDraw,1));