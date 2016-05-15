function [ frame_time,color_plane ] = mean_intensity( option,data,time )
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
%         color_plane - Vector of mean intensity of frames processed
%
%% Convert RGB to YCbCr color plane and then calculate
%  mean intensity of each frame
%  and save time stamp of each frame
%
% Create a cascade detector object.
faceDetector = vision.CascadeObjectDetector();
%
color_plane=[];
frame_time=[];
if option == '1'
    count=0;
    [wl,xl,yl,zl]=size(data);
    ty=zeros(wl,xl,yl,zl);
    %% Convert to YCbCr color space
    init_flag='0';
    track_flag='0';
    for k=1:zl
        tx=squeeze(data(:,:,:,k));
        %
        if track_flag == '1'
            % Track the points. Note that some points may be lost.
            [points, isFound] = step(pointTracker, tx);
            visiblePoints = points(isFound, :);
            oldInliers = oldPoints(isFound, :);
            %
            if size(visiblePoints, 1) >= 2 % need at least 2 points
                % Estimate the geometric transformation between the old points
                % and the new points and eliminate outliers
                [xform, oldInliers, visiblePoints] = estimateGeometricTransform(...
                oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);

                % Apply the transformation to the bounding box points
                BBPoints = transformPointsForward(xform, BBPoints);

                % Reset the points
                oldPoints = visiblePoints;
                setPoints(pointTracker, oldPoints);
            end
            % Determining box for region of interest - Forehead
            BB1=BBPoints(2,1)-BBPoints(1,1);
            BBx1=round(BB1*0.10);
            BB2=BBPoints(4,2)-BBPoints(1,2);
            BBy2=BBPoints(1,2)+round(BB2*0.60);
            %
            BBROI(1,1)=BBPoints(1,1)+BBx1;
            BBROI(1,2)=BBy2;
            BBROI(2,1)=BBROI(1,1)+BBx;
            BBROI(2,2)=BBROI(1,2);
            BBROI(3,1)=BBROI(2,1);
            BBROI(3,2)=BBROI(2,2)+BBy;
            BBROI(4,1)=BBROI(1,1);
            BBROI(4,2)=BBROI(3,2);
        else
            % Run the face detector on the frame
            BB = step(faceDetector, tx);
            % Convert the first box into a list of 4 points
            BBPoints = bbox2points(BB(1, :));
            % Determining box for region of interest - Forehead
            BB1=BBPoints(2,1)-BBPoints(1,1);
            BBx1=round(BB1*0.10);
            BBx=BBPoints(2,1)-BBPoints(1,1)-BBx1-BBx1;
            BB2=BBPoints(4,2)-BBPoints(1,2);
            BBy2=BBPoints(1,2)+round(BB2*0.60);
            BBy=BBPoints(4,2)-BBy2;
            %
            BBROI(1,1)=BBPoints(1,1)+BBx1;
            BBROI(1,2)=BBy2;
            BBROI(2,1)=BBROI(1,1)+BBx;
            BBROI(2,2)=BBROI(1,2);
            BBROI(3,1)=BBROI(2,1);
            BBROI(3,2)=BBROI(2,2)+BBy;
            BBROI(4,1)=BBROI(1,1);
            BBROI(4,2)=BBROI(3,2);
            %
            % Detect feature points in the face region.
            points = detectMinEigenFeatures(rgb2gray(tx), 'ROI', BB);
            % Create a point tracker and enable the bidirectional error constraint to
            % make it more robust in the presence of noise and clutter.
            pointTracker = vision.PointTracker('MaxBidirectionalError', 2);
            % Initialize the tracker with the initial point locations and the initial
            % video frame.
            points = points.Location;
            initialize(pointTracker, points, tx);
            % Make a copy of the points to be used for computing the geometric
            % transformation between the points in the previous and the current frames
            oldPoints = points;
            %
            
        end
        %
        BB_CROP=[BBROI(1,1) BBROI(1,2) BBx BBy];
        txc=imcrop(tx,BB_CROP);
        txc=rgb2ycbcr(txc);
        crop_size=size(txc);
        if track_flag=='0'
            ty=zeros(crop_size(1),crop_size(2),crop_size(3),zl);
        end
        ty(:,:,:,k)=txc;
        track_flag='1';
    end
    % Calculate mean intensity using all channels
    % fd1=mean(mean(mean(ty(:,:,:,1:zl))));
    % fd2=squeeze(fd1(1,1,1,:));
    %% Calcualte mean intensity only of a channel 1-Y 2-Cb 3-Cr
    %%% color=2;
    %%% tz=squeeze(ty(:,:,color,:));
    %%% fd1=mean(mean(tz(:,:,1:zl)));
    %%% fd2=squeeze(fd1(:,1,:));
    %% Added mean calculation as in option 2
    fd1=mean(mean(mean(ty(:,:,:,1:zl))));
    fd2=squeeze(fd1(1,1,1,:));
    %%
    fd3=fd2';
    ft1=time';
    color_plane=[color_plane fd3];
    frame_time=[frame_time ft1];
    count=count+zl;
    color_plane=color_plane';
    %%
    color_plane=color_plane./sum(color_plane);
    tt=(color_plane - min(color_plane)) / ( max(color_plane) - min(color_plane) );
    color_plane=tt';
    %%
    frame_time=frame_time';
else
    count=0;
    [wl,xl,yl,zl]=size(data);
    fd1=mean(mean(mean(data(:,:,:,1:zl))));
    fd2=squeeze(fd1(1,1,1,:));
    fd3=fd2';
    color_plane=[color_plane fd3];
    count=count+zl;
    color_plane=color_plane./sum(color_plane);
    tt=(color_plane - min(color_plane)) / ( max(color_plane) - min(color_plane) )
    color_plane=tt';
    frame_time=time;
end
% save_cp=color_plane;
% aa=1;
% bb=linspace(1/30,1/30,30);
% color_plane=filter(bb,aa,color_plane);
% fig_count=fig_count+1;
% fig=figure(fig_count);
% plot(frame_time,color_plane,'r')
% hold on
% plot(frame_time,save_cp,'b')
% drawnow
% hold off
%

end

