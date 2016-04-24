function rr = dummy_respiration(frames)

persistent videos;
if isempty(videos)
    videos = {};
end

persistent counter;
if isempty(counter)
    counter = 1;
end

video = cat(4, frames.image);
videos{counter} = video;
counter = counter + 1;

% if counter == 21
%     for i = 1:20
%         play_video(videos{1,i});
%     end
% end

rr = 15;