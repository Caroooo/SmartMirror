function [ gray_snap,rgb_snap ] = capture_snapshot( )
%capture_snapshot.m Capture Image of Person In Front of Camera
% This function captures the snapshot of the person in front of the
% camera on pressing the Enter Key in grayscale as well as RGB
%
% Input: None
%
% Output: gray_snap - Captured image of person in grayscale
%         rgb_snap  - Captured image of person in RGB
%

%% Accept input from user to start image capture
disp('Please look straight at the web camera and press Enter')
start = input('\nPress Enter to Start Detection:','s');

%% Capture a snapshot of the person
vid = videoinput('winvideo', 1);
set(vid, 'ReturnedColorSpace', 'grayscale');
gray_snap = getsnapshot(vid);
set(vid, 'ReturnedColorSpace', 'RGB');
rgb_snap = getsnapshot(vid);

end

