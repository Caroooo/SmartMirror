clear all;
close all;

video = VideoReader('mihi-heavy-breathing.avi');
% frames = importdata('shankar.4d');
frames = video.read();
dummy_respiration(frames);
