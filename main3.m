cam = webcam(1);
im = snapshot(cam);
clear('cam');


% Create a cascade detector object.
faceDetector = vision.CascadeObjectDetector();

% Read a video frame and run the detector.
videoFrame      = im;
bbox            = step(faceDetector, videoFrame);

% % Draw the returned bounding box around the detected face.
videoOut = insertObjectAnnotation(videoFrame,'rectangle',bbox,'Face');
figure, imshow(videoOut), title('Detected face');
detectedFace = videoFrame(bbox(2):bbox(2) + bbox(4),bbox(1):bbox(1)...
    + bbox(3),:);
figure,imshow(detectedFace)

wavelength = [pi/2 pi/(2^(3/2)) pi/4 pi/(2^(5/2)) pi/8];

orientation = [0 pi/8 pi/4 3*pi/8 pi/2 5*pi/8 3*pi/4 7*pi/8]*180/pi;
sigma = 2*pi;
red = 100;
% 
%  g1 = gabor(50,orientation);
%  g2 = gabor(50,orientation);

for i = 1 :size(wavelength,2)
    for j = 1 : size(orientation,2)
        g = gaborfil2(red, orientation(1,j),wavelength(1,i),sigma);
        figure, imshow(g)
    end
end

% figure;
% subplot(2,8,1)
% for p = 1:length(g1)
%     subplot(2,8,p);
%     imshow(real(g1(p).SpatialKernel),[]);
%     f = g1(p).SpatialFrequencyBandwidth;
%     theta  = g1(p).Orientation;
% %     title(sprintf('Re[h(x,y)], \\f = %d, \\theta = %d',f,theta));
% end
% 
% for p = 1:length(g2)
%     subplot(2,8,p+8);
%     imshow(real(g2(p).SpatialKernel),[]);
%     f = g2(p).SpatialFrequencyBandwidth;
%     theta  = g2(p).Orientation;
% %     title(sprintf('Re[h(x,y)], \\f = %d, \\theta = %d',f,theta));
% end