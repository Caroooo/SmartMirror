function [ rgb_butter_hr ] = hr_filter( frame_count,time_taken,rgb_mean )
% hr_filter.m - Filter RGB Mean Intensity To Extract Heart Rate Signals
% Filter Mean RGB Intensity for Heart Rate Determination
% using Butterworth filter
% Frequencies between 0.75 Hz and 4.0 Hz
% corresponding to 45 beats per miniute and 240 beats per minute
% respectively
%
% Input: frame_count - number of frames in input
%        time_taken - time taken for capture of frames
%        rgb_mean - RGB Mean Intensity signal
%
% Output: rgb_butter_hr - Filltered Signal for Heart Rate Extraction
%
%% Filter Mean RGB Intensity for Heart Rate Determination
%
sample_rate=frame_count/time_taken;
l_cutoff=0.75;
h_cutoff=4.0;
[B,A]=butter(2,[l_cutoff h_cutoff]/(sample_rate/2),'bandpass');
rgb_butter_hr=filter(B,A,rgb_mean);
%

end

