function [ ibi ] = extract_ibi( hr )
% extract_ibi.m - Extract Inter-beat Interval and plot heart rate
%                 variability
%
% Input: hr - heart rates extracted
%
% Output: ibi - Inter-beat interval in seconds
%
%%
sz=size(hr);
frame_count=sz(2);

ibi=[];

for i=1:frame_count
    ibi = [ibi round(60*1000/hr(i))];
end
%

end

