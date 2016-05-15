function [ pname,pheight,pweight,pgender,pdob,oimg ] = capture_snapshot(  )
% capture_snapshot.m - Capture grayscale snapshot and identify the person
%
% Input: none
%
% Output: pid - id of person detected
%         pname - name of person
%         pheight - height in centimeters of person
%         pweight - weight in kilograms of person
%         pgender - gender of person
%         pdob - date of birth of person
%         oimg - image from database of detected person
%
%% Capture Grayscale Snapshot to identify person
%
%persistent h_fig;
%persistent h1;
%persistent h2;
%persistent h3;
%persistent h4;
%
%h_fig=figure(1);
%h1=subplot(2,1,1);
%h2=subplot(3,2,2);
%h3=subplot(3,2,3);
%h4=subplot(2,1,2);
%
vid = videoinput('winvideo', 1);
set(vid, 'ReturnedColorSpace', 'grayscale');
img = getsnapshot(vid);
faceDetector = vision.CascadeObjectDetector();
BB = step(faceDetector, img);
img=imcrop(img,BB);
% subplot(2,1,1);
% imshow(img);
% hold on
img=imresize(img,[112,92]);
%
% Call function to identify person
[pname,pheight,pweight,pgender,pdob,oimg] = id_person( img );
% h1=subplot(2,1,2);imshow(oimg);
% title('Detected Person');
% drawnow
%
% Clear up
delete(vid)
clear vid
clear img
%

end

