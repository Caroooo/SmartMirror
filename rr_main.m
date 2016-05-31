clear all;
close all;

frame_rate = 58;

video = VideoReader('miha_fh.mp4');
%video = VideoReader('forehead.mp4');
%frames = importdata('vukan.4d');
frames = video.read();
sizeFrame = size(frames, 4);
time = sizeFrame/frame_rate;
timeStamps = 1:(1/frame_rate):(time + 1); 
dummy_respiration_for_video(frames, timeStamps(1:sizeFrame))

