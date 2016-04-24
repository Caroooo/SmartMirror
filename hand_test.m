clear all;

cam = webcam;

handDetector = vision.CascadeObjectDetector('hands.xml');

while true
    pause;
    im = snapshot(cam);
    bboxes = step(handDetector, im);
    IHands = insertObjectAnnotation(im, 'rectangle', bboxes, 'Branko');  
    imshow(IHands);
end
    