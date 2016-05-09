function load_video(file_name)

v = VideoReader(file_name);
max_frames = 600;

output = zeros(v.Width, v.Height, 3, ceil(v.duration) * ceil(v.FrameRate));

while hasFrame(v)
    video = readFrame(v);
end