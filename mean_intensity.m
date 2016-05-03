function [ frame_time,rgb_mean ] = mean_intensity( option,vid,time )
% mean_intensity.m - Calculate the mean intensity of the video frames
% 
% Input: option - Values '1' and '2'
%        1 - Video Input Class is 'videoinput' and colorspace is RGB
%        2 - Video Input Class is '4-D'
%            Height x Width x 3 x Number of Frames
%            Eg. 480x640x3x50
%            where video resolution is 640x480, 3 indicates RGB
%            50 is the number of video frames in the input
%        Video should contain at least 6 times frame rate in order to 
%        calculate respiration rate.
%        Eg. if frame rate is 30 fps, you need 180 frames
%        Video should contain at least 3 times frame rate in order to
%        calculate heart rate.
%        Eg. if frame rate is 30 fps, you need 180 frames
%        vid - Video input in the format depending on option
%              'time' input is not required to be provided for 
%              option '1' as it is contained in vid
%        time - Time in seconds of each video frame
%               Required when option 2 is chosen
%               Class should be 'double' and
%               size should be Number of Frames x 1
%               Eg. 50x1 indicates that time consists of
%               50 numbers corresponding to 50 frames
%               The number of frames should be the same as the frames
%               provided in the video input 'vid'
%
% Output: frame_time - Vector of time values of the RGB frames (cumulative)
%         rgb_mean - Vector of mean intensity of RGB frames processed
%
%% Calculate mean intensity of each frame (mean of RGB of each frame)
%  and save time stamp of each frame
%
if option == '1'
    count=0;
    while(vid.FramesAvailable >= 1)
        [data time] = getdata(vid);
        [wl,xl,yl,zl]=size(data);
        fd1=mean(mean(mean(data(:,:,:,1:zl))));
        fd2=squeeze(fd1(1,1,1,:));
        fd3=fd2';
        ft1=time';
        if count==0
            rgb_mean=fd3;
            frame_time=ft1;
        else
            rgb_mean=[rgb_mean fd3];
            frame_time=[frame_time ft1];
        end
        count=count+zl;
    end
    rgb_mean=rgb_mean';
    frame_time=frame_time';
    % Clear up
    delete(vid)
    clear vid
else
    count=0;
    data = vid;
    [wl,xl,yl,zl]=size(data);
    fd1=mean(mean(mean(data(:,:,:,1:zl))));
    fd2=squeeze(fd1(1,1,1,:));
    fd3=fd2';
    if count==0
        rgb_mean=fd3;
    else
        rgb_mean=[rgb_mean fd3];
    end
    count=count+zl;
    rgb_mean=rgb_mean';
    frame_time=time;
    % Clear up
    clear vid
end

%

end

