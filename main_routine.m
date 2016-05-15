% main_routine.m - Smart Mirror opening routine
%
clear all
clc
fig_count=0;
% Stream time in seconds for video recording
stream_time=30;
%
hr_display=[];
ibi_display=[];
rr_display=[];
%% Capture Grayscale Snapshot to identify person
%
[pname,pheight,pweight,pgender,pdob,oimg] = capture_snapshot();

%% Get Reminders
%
[ reminders ] = get_reminders(pname);
        
%% Capture Video
% No. of frames = FramesPerTrigger*(TriggerRepeat +1)
%
start_time=datestr(now,'yyyymmddHHMM');
tic
elapsed=toc;
while true
    vid = videoinput('winvideo',1);
    vid.FramesPerTrigger = 60;
    vid.TriggerRepeat = Inf;
    vid.FrameGrabInterval = 1;
    vid.TriggerFrameDelay = 5;
    start(vid)
    while(islogging(vid))
        % Calculate mean intensity of each frame (mean of RGB of each frame) and
        % save time stamp of each frame
        %
        % Wait till 200 frames are available in buffer
        while(vid.FramesAvailable < 200)
        end
        %
        [data time] = getdata(vid);
        [frame_time,rgb_mean] = mean_intensity('1',data,time);
        %
        % Perform FFT and plot heart rate
        %
        [ hr,ibi ] = extract_hr(frame_time,rgb_mean);
        %
        % Perform FFT and plot respiration rate
        %
        %%
        [ rr ] = extract_rr(frame_time,rgb_mean);
        %
        %%
        hr_display=[hr_display hr];
        ibi_display=[ibi_display ibi];
        rr_display=[rr_display rr];
        %
        %%% subplot(2,1,2);
        %%% drawnow
        %%% hold on
        %%% XT=['Inter-beat Interval and Heart Rate Variability Plot'];
        %%% title(XT);
        %%% ff_ibi=linspace(1,numel(ibi_display),numel(ibi_display));
        %%% plot(ff_ibi,ibi_display,'r');
        %%% xlabel('Beat Number')
        %%% ylabel('Inter-beat Interval - Seconds')
        %
        
           
        clc
        for pi=1:15
            fprintf('\n');
        end
        fprintf('\t\t\t\t\t\t\t');
        DT=['Good day ',pname];
        fprintf('%s',DT);
        fprintf('\n');
        fprintf('\t\t\t\t\t\t\t');
        DT=['Date and Time: ',datestr(datetime('now'))];
        fprintf('%s',DT);
        fprintf('\n');
        fprintf('\t\t\t\t\t\t\t');
        % removing outliers from the mean
        DT=['Avg Heart Rate Is ',num2str(round(mean(hr_display(round(hr_display)~=20)))),' Beats Per Minute'];
        fprintf('%s',DT);
        fprintf('\n');
        fprintf('\t\t\t\t\t\t\t');
        % removing outliers from the mean
        DT=['Avg Respiration Rate Is ',num2str(round(mean(rr_display(rr_display~=0)))),' Breaths Per Minute'];
        fprintf('%s',DT);
        fprintf('\n');
        fprintf('\t\t\t\t\t\t\t');
        DT=['Last Inter-beat Interval Is ',num2str(round(ibi_display(end))),' Milliseconds'];
        fprintf('%s',DT);
        fprintf('\n');
        fprintf('\t\t\t\t\t\t\t');
        DT=['Max Inter-beat Interval Is ',num2str(round(max(ibi_display))),' Milliseconds'];
        fprintf('%s',DT);
        fprintf('\n');
        fprintf('\t\t\t\t\t\t\t');
        DT=['Min Inter-beat Interval Is ',num2str(round(min(ibi_display(ibi_display~=0)))),' Milliseconds'];
        fprintf('%s',DT);
        fprintf('\n');
        fprintf('\t\t\t\t\t\t\t');
        % removing outliers from the mean
        DT=['Avg Inter-beat Interval Is ',num2str(round(mean(ibi_display(ibi_display<2900)))),' Milliseconds'];
        fprintf('%s',DT);
        fprintf('\n\n');
        %
        % Display Reminders
        num_rem=size(reminders,2);
        for remi=1:num_rem
            fprintf('\t\t\t\t\t\t\t');
            DT=[char(reminders{remi})];
            fprintf('%s',DT);
            fprintf('\n');
        end
        %
        elapsed=toc;
        if elapsed > stream_time
            break;
        end
    end
    if elapsed > stream_time
        break;
    end
end
out_file=strcat([start_time,pname,'.csv']);
out_data=zeros(numel(hr_display),3);
for i=1:numel(hr_display)
    out_data(i,1)=round(hr_display(i));
    out_data(i,2)=ibi_display(i);
    out_data(i,3)=round(rr_display(i));
end
csvwrite(out_file,out_data);
stop(vid)
clear vid;

%%


