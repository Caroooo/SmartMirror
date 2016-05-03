function [ hr,ibi ] = extract_hr( frame_time,rgb_mean )
% extract_hr.m - Extract and plot Heart Rate using the filtered signal 
% Extraction performed using Fast Fourier Transform
%
% Input: frame_time - time in seconds of each frame (cumulative)
%        rgb_mean - mean RGB intensity of video frames
%
% Output: hr - Heart Rate in Beats Per Minute at the time interval
%              specified by disp_freq_hr
%         ibi - Inter-beat interval in seconds
%
%%
persistent h3;
sz=size(frame_time);
frame_count=sz(1);
time_taken=frame_time(frame_count)-frame_time(1);

%% Filter Mean RGB Intensity for Heart Rate Determination
%  using Butterworth filter
%  Frequencies between 0.75 Hz and 4.0 Hz
%  corresponding to 45 beats per miniute and 240 beats per minute
%  respectively
%
[rgb_butter_hr] = hr_filter(frame_count,time_taken,rgb_mean);

%% disp_freq_hr - interval of time in seconds at which heart rate is
% calculated
disp_freq_hr=3;

sample_rate=frame_count/time_taken;
disp_rate_hr=floor(sample_rate);
num_readings_hr=round(frame_count/disp_rate_hr);
T_hr=1/sample_rate;
t_hr=(0:(disp_rate_hr*disp_freq_hr)-1)*T_hr;
ff_h=sample_rate*(0:((disp_rate_hr*disp_freq_hr)/2))/(disp_rate_hr*disp_freq_hr);
i1_hr=1;
i2_hr=disp_freq_hr*disp_rate_hr;
%
for i=1:frame_count
    rgb_fft_hr=fft(rgb_butter_hr(i1_hr:i2_hr));
    P2_hr=abs(rgb_fft_hr/frame_count);
    P1_hr=P2_hr(1:round((disp_rate_hr*disp_freq_hr)/2+1));
    P1_hr(2:end-1)=2*P1_hr(2:end-1);
    [tt_hr uu_hr]=max(P1_hr);
    hr(i)=60*ff_h(uu_hr);
    i1_hr=i1_hr+disp_rate_hr;
    i2_hr=i1_hr+(disp_freq_hr*disp_rate_hr)-1;
    if i2_hr > frame_count
        break
    end
end

%% Determine Inter-beat Interval and plot Heart Rate Variability
%
[ ibi ] = extract_ibi(frame_time,rgb_butter_hr);
%

end

