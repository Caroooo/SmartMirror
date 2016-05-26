function boundaries = getBigInterval(array, percentage)
    if nargin < 2
        percentage = 0.75;
    end
%     proba = eyeBinary(location1:location2,:);
% %     subplot(2,3,4);
% %     imshow(proba);
% %     subplot(2,3,5);

%     sumH = sum(~proba,2);
    sumH = array;
    [maxVal, maxInd] = max(sumH);
    sumHLeft = sumH(1:maxInd);
    left = find(sumHLeft < percentage * maxVal, 1, 'last');
    if( isempty(left))
        boundaries(1) = 1;
    else
        boundaries(1) = left;
    end
    sumHRight = sumH(maxInd:end);
    right = find(sumHRight < percentage * maxVal, 1, 'first');
    if isempty(right)
        right = length(sumHRight);
    end
        boundaries(2) = right + maxInd -1;

%     x = 1:length(sumH);
%     plot(x, sumH, 'b', maxInd, maxVal, 'g*', boundariesH, sumH(boundariesH), 'r*');
%     view([90 90]);
%     subplot(2,3,6);