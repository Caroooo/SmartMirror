function [ rgb_butter_rr ] = rr_filter( frame_count,time_taken,rgb_mean )
% rr_filter.m - Filter RGB Mean Intensity To Extract Respiration Rate Signals
% Filter Mean RGB Intensity for Respiration Rate Determination
% using Butterworth filter
% Frequencies between 0.1 Hz and 0.5 Hz
% corresponding to 6 breaths per minute and 30 breaths per minute
% respectively
%
% Input: frame_count - number of frames in input
%        time_taken - time taken for capture of frames
%        rgb_mean - RGB Mean Intensity signal
%
% Output: rgb_butter_rr - Filltered Signal for Heart Rate Extraction
%
%% Filter Mean RGB Intensity for Respiration Rate Determination
%
sample_rate=frame_count/time_taken;
l_cutoff=0.1;
h_cutoff=0.5;
[B,A]=butter(2,[l_cutoff h_cutoff]/(sample_rate/2),'bandpass');
rgb_butter_rr=filter(B,A,rgb_mean);
%

end

