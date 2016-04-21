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

wavelength = [2 2*sqrt(2) 4 4*sqrt(2) 8];

orientation = [0 pi/8 pi/4 3*pi/8 pi/2 5*pi/8 3*pi/4 7*pi/8]*180/pi;

g = gabor(wavelength,orientation); 
 
% figure;
% for p = 1:length(g)
%     figure,
%     imshow(real(g(p).SpatialKernel),[]);
%     f = g(p).Wavelength;
%     theta  = g(p).Orientation;
%     title(sprintf('Re[h(x,y)], \\f = %d, \\theta = %d',f,theta));
% end

DF = rgb2gray(detectedFace);
[mag,phase] = imgaborfilt(DF,g);

for j = 1 : 40
    im = mag(:,:,j).*exp(-1i*phase(:,:,j));
    figure, imshow(real(im),[]);
end