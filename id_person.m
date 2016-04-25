function [ pid,pname,pheight,pweight,pgender,pdob ] = id_person( gray_snap )
%id_person.m Identifies person whose snapshot is provided
% The function takes a graysacle snapshot as input and identifies
% the person.
% The algorithm for face recognition uses the eigenface system which is
% based on pricipal component analysis (PCA).
% The comparison is made against the database of stored images.
% The stored images are in the same format as the input snapshot.
% Once the person is identified, the name, date of birth (MM/DD/YYYY),
% height in centimeters, weight in kilograms and 
% gender (M-Male or F-Female) are retrieved from the file
% data.txt.
%
% Input: grap_snap - Grayscale snapshot of person to be identified
%
% Output: pid     - Person id
%         pname   - Name of person
%         pheight - Height of person in centimeters
%         pweight - Weight of person in kilograms
%         pgender - Gender (M-Male F-Female)
%         pdob    - Date of birth of person (MM/DD/YYYY)
%

%% Image Requirements To Be Met
% Each person's image should be stored serially in directories 
% with prefix 's' followed by serial number
% Size of image should be 480x640
xl=480;
yl=640;
% Image file type should be pgm and files should be serially numbered
% from 1 to 10. For example 1.pgm, 2.pgm and so on
ftype='.pgm';
% number of images per person in training database
num_pic=10;
numd=size(dir('s*'));
numdir=numd(1);
% Number of persons identified by number of directories
num_images=num_pic*numdir;

%% Read Data File for Person Informatiom
fname=fopen('data.txt');
frecord=textscan(fname,'%s %s %d %d %s %s','Delimiter',',');
fclose(fname);

%% Load the database into matrix v
v=load_database(num_pic,numdir,ftype,xl,yl);

%% Initialization
% Training is done on all the pictues in the database. 

%ri=round(15*rand(1,1));         % Randomly pick an index.
%r=w(:,ri);                      % r contains the image we later on will use to test the algorithm
%v=w(:,[1:ri-1 ri+1:end]);       % v contains the rest of the images.
r=zeros(xl*yl,1);
r=reshape(gray_snap,xl*yl,1);
%v=w;


N=15;                           % Number of signatures used for each image.
%% Subtract the mean from v
O=uint8(ones(1,size(v,2)));
m=uint8(mean(v,2));                 % m is the maen of all images.
vzm=v-uint8(single(m)*single(O));   % vzm is v with the mean removed.

%% Calculate eignevectors of the correlation matrix
% We pick N of the available eigenfaces.
L=single(vzm)'*single(vzm);
[V,D]=eig(L);
V=single(vzm)*V;
V=V(:,end:-1:end-(N-1));            % Pick the eignevectors corresponding to the 10 largest eigenvalues.

%% Calculate the signature for each image
cv=zeros(size(v,2),N);
for i=1:size(v,2);
    cv(i,:)=single(vzm(:,i))'*V;    % Each row in cv is the signature for one image.
end

%% Recognition
%  Now, we run the algorithm and see if we can correctly recognize the face.
subplot(121);
imshow(reshape(r,xl,yl));title('Looking for ...','FontWeight','bold','Fontsize',16,'color','red');

subplot(122);
p=r-m;                              % Subtract the mean
s=single(p)'*V;
z=[];
for i=1:size(v,2)
    z=[z,norm(cv(i,:)-s,2)];
    if(rem(i,5)==0),imshow(reshape(v(:,i),xl,yl)),end;
    drawnow;
end

[a,i]=min(z);
subplot(122);
imshow(reshape(v(:,i),xl,yl));title('Found!','FontWeight','bold','Fontsize',16,'color','red');

%% Get Person Name and Other Parameters
numrows=max(cellfun('size',frecord,1));
xperson=num2str(ceil(i/num_pic));
%xperson=personLabel{1};
for i=1:numrows
    pid=frecord{1}{i};
    if pid==xperson
        pname=frecord{2}{i};
        pheight=frecord{3}(i);
        pweight=frecord{4}(i);
        pgender=frecord{5}{i};
        pdob=frecord{6}{i};
        break;
    end
end

end
