function save_video(video, name)

v = VideoWriter(name);
open(v);

dims = size(video);
len = dims(4);

for i = 1:len
    writeVideo(v, video(:,:,:,i));
end

close(v);