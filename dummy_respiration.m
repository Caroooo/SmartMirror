function rr = dummy_respiration(frames, timeStamps)
persistent videos;
if isempty(videos)
    videos = {};
end

persistent counter;
if isempty(counter)
    counter = 1;
end

video = frames;
videos{counter} = video;
counter = counter + 1;
timeStampsSize = size(timeStamps, 2);
totalTime = timeStamps(timeStampsSize) - timeStamps(1);

% Average signal over R, G, B channel
framesAveraged = permute(squeeze(sum(sum(video, 1), 2)/((size(frames, 1)*size(frames, 2)))), [2, 1]);

% Detrend signal over R, G, B channels
N = size(framesAveraged, 1); % Number of points
e = ones(N,1); % building of the 2nd diff. matrix
L = spdiags([e -2*e e], 0:2, N-2, N);
alpha = 10; % the control parameter, larger -> smoother
detrendedFrames = inv(speye(N,N)+alpha^2*(L'*L))*framesAveraged; % Estimation/smoothing

% Normalize signal over R, G, B channelsstd
meanValue = mean(detrendedFrames, 1);
stdValue = std(detrendedFrames, [], 1);
normalizedFrames = bsxfun(@rdivide, bsxfun(@minus, detrendedFrames, meanValue), stdValue);

% Permuate data so that the dimension matches sources x samples
normalizedFrames = permute(normalizedFrames, [2, 1]);

% Apply ICA to the normalized data; search for three sources
sources = jadeR(normalizedFrames, 3) * normalizedFrames;

% Permuate data so that the dimension matches smaples x sources
sources = permute(sources, [2, 1]);

% Find the source with the highest peak
[value, index] = max(sources(:));
[row, column] = ind2sub(size(sources), index);
channel = sources(:, column);

% Smooth the signal using a five-point moving average filter
windowSize = 5;
b = (1/windowSize)*ones(1,windowSize);
smoothedSignal = filter(1, b, channel);

% Smooth the signal using a hamming window filter
bandPassFilter = fir1(128, [0.07 0.4]);
hummingChannel = filter(bandPassFilter, 1, smoothedSignal);
plot(timeStamps, hummingChannel, 'r');

% Spline cubic function data interpolation
desiredSampling = 256;
[resampledData, TResampledData] = resample(hummingChannel, timeStamps, desiredSampling, 3, 1, 'spline');

% Lomb periodogram PSD
[pxx, f] = plomb(resampledData,TResampledData);
f = f/totalTime;
indecies = f(f >= 0.15 & f <= 0.4);
endIndex = size(indecies, 1);
startSample = find(ismember(f, [indecies(1)]));
endSample = find(ismember(f, [indecies(endIndex)]));
f = f(startSample:endSample);
pxx = pxx(startSample:endSample);
[value, index] = max(pxx);
[row, column] = ind2sub(size(pxx), index);

rr = f(column)*60;