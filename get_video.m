function video = get_video(duration, cam)

% Constants
MAX_FPS = 40;

% Pre-allocate memory
temp = snapshot(cam);
dims = size(temp);
video = zeros(dims(1), dims(2), dims(3), MAX_FPS*duration);
video = uint8(video);

% Start stopwatch
start_time = clock;

i = 1;

% Record video
while etime(clock, start_time) < duration
    im = snapshot(cam);
    video(:,:,:,i) = im;
    i = i + 1;
end

video = video(:,:,:,1:i-1);