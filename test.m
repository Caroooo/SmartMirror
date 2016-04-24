clear all;
close all;

cam = webcam;
I = snapshot(cam);

eyeDetector = vision.CascadeObjectDetector('EyePairSmall');
bboxes = step(eyeDetector, I);

% Annotate detected faces
IEye = insertObjectAnnotation(I, 'rectangle', bboxes, 'Oko');   

imshow(IEye);