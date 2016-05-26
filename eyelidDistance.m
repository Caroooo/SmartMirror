function eyeDistance = eyelidDistance(eye, Y_THRESHOLD)

[m, n] = size(eye);
doubleEye = im2double(uint8(eye));

% subplot(2,1,1);
% plot(sum(eye));
% subplot(1,2,1)
% histogram(im2uint8(doubleEye),0:255)
% Histogram equalization
eye = double(im2uint8(imadjust(doubleEye, [min(min(doubleEye)) max(max(doubleEye))],[0 1],1)));
% subplot(1,2,2)
% histogram(im2uint8(imadjust(doubleEye, [min(min(doubleEye)) max(max(doubleEye))],[0 1],1)),0:255);
% Detect if there is eyebrow, so it can be removed
summary = sum(eye,2);
[~, eyebrowLocs ] = findpeaks(summary);

% Convert to binary image
eyeBinary = eye > 55;

% 
% subplot(3,1,3);
% % imshow(uint8(eye));
% imshow(eyeBinary);

if ~isempty(eyebrowLocs)
    if eyebrowLocs(1) ~= 1 && eyebrowLocs(1) < round(m/2.2)
    
    % Removing the eyebrow
    eyeBinary(1:eyebrowLocs(1) - 1,:) = ones(eyebrowLocs(1)-1,n);
    end
end
% Taking horizontal mean values
mBinary = mean(eyeBinary,2);

% Sigma function
sigmaBinary = zeros(m,1);
for i = 1 : m
    sigmaBinary(i,1) = sum((eyeBinary(i,:) - mBinary(i,:)).^2)/n;
end

% First derivative of sigma function
difVarBinary = diff(sigmaBinary,1);
[pksBinaryPositive, locsBinaryPositive] = findpeaks(difVarBinary);
[pksBinaryNegative, locsBinaryNegative] = findpeaks(-difVarBinary);
pksBinary = [pksBinaryPositive',-pksBinaryNegative'];
locsBinary = [locsBinaryPositive',locsBinaryNegative'];

[location1, location2] = getDistance(pksBinary, locsBinary);
% disp(locsBinary);
distance = abs(location1 - location2);
% subplot(2,3,1);
% imshow(uint8(eye));
% % subplot(3,1,3);
% imshow(eyeBinary);
% drawnow;
% subplot(2,3,3);
% plot(diff(sigmaBinary,1));
% view([90 90]);
% subplot(2,3,4);
% plot(histEye);
% subplot(2,3,5);
% plot(histDiff);
% subplot(2,3,6);
% imshow(insertText(zeros(50, 50), [0, 0], distance, 'FontSize', 30));
percent = 0;

if distance < Y_THRESHOLD
    fprintf('Absolute\n');
    eyeDistance = 0;
else
        if location1 ~= 0 || location2 ~= 0
            if location1 < location2
                extract = eyeBinary(location1:location2,:);
%                 subplot(2,3,2);
%                 imshow(extract);
                sumH = sum(~extract,2);
                boundariesH = getBigInterval(sumH,0.85);
                sumV = sum(~extract, 1);
                boundariesV = getBigInterval(sumV,0.65);


                cut = extract(boundariesH(1):boundariesH(2),...
                    boundariesV(1):boundariesV(2));
%                 subplot(2,3,3);
%                 imshow(cut);
%                 subplot(2,3,4);
%                 x = 1:length(sumH);
%                 plot(x, sumH, 'b', boundariesH, sumH(boundariesH), 'r*');
%                 view([90 90]);
%                 subplot(2,3,5);
%                 x = 1:length(sumV);
%                 plot(x, sumV, 'b', boundariesV, sumV(boundariesV), 'r*');
%                 subplot(2,3,6);
                percent = 100 * sum(sum(cut)) / (size(cut,1) * size(cut,2));
%                 imshow(insertText(zeros(50, 50), [0, 0], percent, 'FontSize', 15));
%                 drawnow;

                %plot(sum_v);
                %V = axis;
                %axis([V(1) V(2) 0 30]);
                %imshow(insertText(zeros(50, 50), [0, 0], distance, 'FontSize', 30));
            end
        end
        
    if percent > 25
        fprintf('Percent\n');
        eyeDistance = 0;
    else
        eyeDistance = distance;
    end
end
% subplot(2,3,6);
% imshow(insertText(zeros(50, 50), [0, 0], eyeDistance, 'FontSize', 30));
% subplot(2,1,2);
% imshow(uint8(eye));