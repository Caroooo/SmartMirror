clear all;
close all;

video = VideoReader('mihaela-30-sec.avi');
%frames = importdata('vukan.4d');
frames = video.read();
sizeFrame = size(frames, 4);
time = sizeFrame/30;
timeStamps = 1:(1/30):(time + 1); 
dummy_respiration_for_video(frames, timeStamps(1:sizeFrame))
