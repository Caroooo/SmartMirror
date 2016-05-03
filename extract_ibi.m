function [ ibi ] = extract_ibi( frame_time,rgb_butter_hr )
% extract_ibi.m - Extract Inter-beat Interval and plot heart rate
%                 variability
%
% Input: frame_time - time in seconds of each frame (cumulative)
%        rgb_butter_hr - filtered signal
%
% Output: ibi - Inter-beat interval in seconds
%
%%
persistent h4;
sz=size(frame_time);
frame_count=sz(1);

chk_field1=rgb_butter_hr(1);
beat_count=0;
cycle='1';
chk_time1=frame_time(1);
chk_field2=rgb_butter_hr(2);
if chk_field2 < chk_field1
    dorder='D';
else
    dorder='A';
end
for i=2:frame_count
    if dorder == 'A'
       if rgb_butter_hr(i) < chk_field1
           dorder = 'D';
           chk_time2=frame_time(i);
           chk_field1 = rgb_butter_hr(i);
           cycle='2';
       else
           chk_field1=rgb_butter_hr(i);
       end
    else
        if rgb_butter_hr(i) > chk_field1 
           dorder = 'A';
           chk_time2=frame_time(i);
           chk_field1 = rgb_butter_hr(i);
           cycle='2';
        else
            chk_field1=rgb_butter_hr(i);
       end
    end
    if cycle=='2'
        beat_count=beat_count+1;
        ibi(beat_count)=chk_time2-chk_time1;
        chk_time1=chk_time2;
        cycle=1;  
    end
end
subplot(2,1,2);
drawnow
hold on
XT=['Inter-beat Interval and Heart Rate Variability Plot'];
title(XT);
ff_ibi=linspace(1,numel(ibi),numel(ibi));
plot(ff_ibi,ibi,'r');
xlabel('Beat Number')
ylabel('Inter-beat Interval - Seconds')
%

end

