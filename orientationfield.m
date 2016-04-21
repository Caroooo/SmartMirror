function orientation=orientationfield(a)
a = im2double(rgb2gray(a));
hy=fspecial('sobel');
hx=hy';
gx=conv2(hx,a);
gy=conv2(hy,a);
gyy=0;
gxx=0;
for i=1:size(gx,1)
    for j=1:size(gx,2)
        gyy=gyy + 2*gx(i,j)*gy(i,j);
        gxx=gxx + (gx(i,j))^2 - (gy(i,j))^2;
    end
end
orientation=0.5*atan2(gyy,gxx);