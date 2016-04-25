function [ out ] = load_database( num_pic,numdir,ftype,xl,yl )
%load_database.m - This function loads the database of images in a form
%                  suitable for face recognition
%
% Input: num_pic - number of pictures per person in database
%        numdir  - number of persons in database
%        ftype   - file extension of images
%        xl,yl   - image size xl*yl
%
% Output: out - complete image database in appropriate format

persistent loaded;
persistent w;

if(isempty(loaded))
    v=zeros(xl*yl,num_pic*numdir);
    for i=1:numdir
        cd(strcat('s',num2str(i)));
        for j=1:num_pic
            a=imread(strcat(num2str(j),ftype));
            v(:,(i-1)*num_pic+j)=reshape(a,xl*yl,1);
        end
        cd ..
    end
    w=uint8(v); % Convert to unsigned 8 bit numbers to save memory
end
loaded=1;       % Set 'loaded' to aviod loading the database again
out=w;
