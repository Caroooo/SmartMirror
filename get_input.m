function input = get_input()

global cam;

if isempty(cam)
    cam = webcam;
end

persistent frames;

if isempty(frames)
    frames = 0;
end

imageRGB = snapshot(cam);

input = fliplr(imageRGB);
frames = frames + 1;
fprintf('FPS = %f\n', 1/toc);
tic;