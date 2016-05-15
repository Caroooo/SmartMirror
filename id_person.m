function [ pname,pheight,pweight,pgender,pdob,oimg ] = id_person( gray_snap )
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
% Output: pname   - Name of person
%         pheight - Height of person in centimeters
%         pweight - Weight of person in kilograms
%         pgender - Gender (M-Male F-Female)
%         pdob    - Date of birth of person (MM/DD/YYYY)
%         oimg    - Snapshot from database of identified person
%

%% 
% Size of image should be 112x92
image_dims = [112, 92];
% Convert input image to vector
i_img = zeros(prod(image_dims), 1);
i_img(:, 1) = gray_snap(:);
input_image = i_img;
% Each person's image should be stored in directory 'imgdb' 
input_dir = 'imgdb';
% Image file type should be pgm and files should be named
% 
ftype='.pgm';
% Get image filenames
filenames = dir(fullfile(input_dir, '*.pgm'));
% Total number of images in database
num_images = numel(filenames);
% Read images
images = [];
for n = 1:num_images
    filename = fullfile(input_dir, filenames(n).name);
    img = imread(filename);
    if n == 1
        images = zeros(prod(image_dims), num_images);
    end
    images(:, n) = img(:);
end

%% Read Data File for Person Informatiom
fname=fopen('data.txt');
frecord=textscan(fname,'%s %d %d %s %s','Delimiter',',');
fclose(fname);

%%
% steps 1 and 2: find the mean image and the mean-shifted input images
mean_face = mean(images, 2);
shifted_images = images - repmat(mean_face, 1, num_images);

% steps 3 and 4: calculate the ordered eigenvectors and eigenvalues
[evectors, score, evalues] = princomp(images');

% step 5: only retain the top 'num_eigenfaces' eigenvectors (i.e. the principal components)
num_eigenfaces = 20;
evectors = evectors(:, 1:num_eigenfaces);

% step 6: project the images into the subspace to generate the feature vectors
features = evectors' * shifted_images;

% calculate the similarity of the input to each training image
feature_vec = evectors' * (input_image(:) - mean_face);
similarity_score = arrayfun(@(n) 1 / (1 + norm(features(:,n) - feature_vec)), 1:num_images);

% find the image with the highest similarity
[match_score, match_ix] = max(similarity_score);

match_file1=filenames(match_ix);
match_file2=match_file1.name;
match_name=strsplit(match_file2,'_');
match_name=upper(char(match_name(1)));

% display the result
% figure, imshow([input_image reshape(images(:,match_ix), image_dims)]);
% title(sprintf('matches %s, score %f', filenames(match_ix).name, match_score));

%% Get Person Name and Other Parameters

numrows=max(cellfun('size',frecord,1));
match_flag='0';
for i=1:numrows
    pname=upper(frecord{1}{i});
    tf=strcmp(pname,match_name);
    if tf
       pheight=frecord{2}(i);
       pweight=frecord{3}(i);
       pgender=frecord{4}{i};
       pdob=frecord{5}{i};
       match_flag='1';
       break;
    end
end
if match_flag=='0'
    pname='Unknown';
    pheight='';
    pweight='';
    pgender='';
    pdob='';
end

oimg=gray_snap;

end
