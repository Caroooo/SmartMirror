clear all;

cam = webcam;

cnt = 1;
prefix = 'hands/branko/branko';
format = '.JPEG';

while true
    pause;
    im = snapshot(cam);
    imshow(im);
    imwrite(im, strcat(prefix, num2str(cnt), format));
    cnt = cnt + 1;
end