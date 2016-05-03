function [ rr ] = extract_rr( frame_time,rgb_mean )
% extract_rr.m - Extract and plot Respiration Rate using the filtered signal 
% Extraction performed using Fast Fourier Transform
%
% Input: frame_time - time in seconds of each frame (cumulative)
%        rgb_mean - mean RGB intensity of video frames
%
% Output: rr - Respiration Rate in Breaths Per Minute at the time interval
%              specified by disp_freq_rr
%
%%
persistent h2;
sz=size(frame_time);
frame_count=sz(1);
time_taken=frame_time(frame_count)-frame_time(1);

%% Filter Mean RGB Intensity for Respiration Rate Determination
%  using Butterworth filter
%  Frequencies between 0.1 Hz and 0.5 Hz
%  corresponding to 6 breaths per minute and 30 breaths per minute
%  respectively
%
[rgb_butter_rr] = rr_filter(frame_count,time_taken,rgb_mean);

%% disp_freq_rr - interval of time in seconds at which respiration rate is
% calculated
disp_freq_rr=6;

sample_rate=frame_count/time_taken;
disp_rate_rr=floor(sample_rate);
num_readings_rr=round(frame_count/disp_rate_rr);
T_rr=1/sample_rate;
t_rr=(0:(disp_rate_rr*disp_freq_rr)-1)*T_rr;
ff_r=sample_rate*(0:((disp_rate_rr*disp_freq_rr)/2))/(disp_rate_rr*disp_freq_rr);
i1_rr=1;
i2_rr=disp_freq_rr*disp_rate_rr;
%
for i=1:frame_count
    rgb_fft_rr=fft(rgb_butter_rr(i1_rr:i2_rr));
    P2_rr=abs(rgb_fft_rr/frame_count);
    P1_rr=P2_rr(1:round((disp_rate_rr*disp_freq_rr)/2+1));
    P1_rr(2:end-1)=2*P1_rr(2:end-1);
    [tt_rr uu_rr]=max(P1_rr);
    rr(i)=60*ff_r(uu_rr);
    i1_rr=i1_rr+disp_rate_rr;
    i2_rr=i1_rr+(disp_freq_rr*disp_rate_rr)-1;
    if i2_rr > frame_count
        break
    end
end
%
sum_rr=0;
for ir=1:numel(rr)
    sum_rr=sum_rr+rr(ir);
    rr_mean(ir)=sum_rr/ir;
end
%

end

