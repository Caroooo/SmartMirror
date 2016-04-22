function input = get_input()

global cam;

if isempty(cam)
    cam = webcam;
end

% persistent frames;
% 
% if isempty(frames)
%     frames = 0;
% end
% frames = frames + 1;



% Get image from camera
imageRGB = snapshot(cam);

% Mirror the image so it works like a... Mirror
input = fliplr(imageRGB);

