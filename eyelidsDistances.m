function [dL, dR] = eyelidsDistances(eyes, leftMaximumOpened, rightMaximumOpened)
if nargin < 7
   rightMaximumOpened = 7;
end
if nargin < 2
   leftMaximumOpened = 7;
   rightMaximumOpened = 7;
end
eyesGray = rgb2gray(eyes);
[m, n] = size(eyesGray);
leftEye = double(eyesGray(:,1:n/2 - 10));
rightEye = double(eyesGray(:,n/2 + 1 + 10:end));

dL = eyelidDistance(leftEye,leftMaximumOpened*0.4);
dR = eyelidDistance(rightEye,rightMaximumOpened*0.4);
% dR = 0;
% % dL = 0;
end
