function g=gaborfil2(red,teta,sigma,frekvencija)
teta = pi/2 - teta;
g=zeros(red,red);
%teta=teta/pi*180;
%T=[cos(teta) ,sin(teta);-sin(teta), cos(teta)];
fix=cos(2*teta);
fiy=sin(2*teta);
gaus=fspecial('gaussian',red);
fixp=0;
fiyp=0;
for i=1:red
    for j=1:red
       fixp=fixp + gaus(i,j)*fix;
       fiyp=fiyp + gaus(i,j)*fiy; 
    end
end
teta=0.5*atan2(fiyp,fixp);

for x=1:red
    for y=1:red
        xt = (x-((red)/2))*cos(teta)+(y-((red)/2))*sin(teta);
        yt = -(x-((red)/2))*sin(teta)+(y-((red)/2))*cos(teta);
        %[xt;yt]=T.*[x-(red-1)/2;y-(red-1)/2];
        g(x,y)=cos(2*pi*frekvencija*xt).*exp(-0.5*(xt.^2 + yt.^2)/sigma^2);
    end
end