function play_video(video)

x = size(video);
num = x(4);

for i = 1:num
    im = video(:,:,:,i);
    imshow(im);
end