function rr = dummy_respiration(images, timeStamps)

persistent videos;
if isempty(videos)
    videos = {};
end

persistent counter;
if isempty(counter)
    counter = 1;
end

%video = cat(4, frames.image);
%videos{counter} = video;
%counter = counter + 1;
video = frames;

% Average over R, G, B channels

framesAveraged = permute(squeeze(sum(sum(video, 1), 2)*((size(frames, 1)*size(frames, 2)))), [2, 1]);
% figure; plot(framesAveraged, 'g');

%Detrend over R, G, B channels
N=size(framesAveraged, 1); % Number of points
e=ones(N,1); % building of the 2nd diff. matrix
L=spdiags([e -2*e e], 0:2, N-2, N);

alpha=10; % the control parameter, larger -> smoother

detrendedFrames = inv(speye(N,N)+alpha^2*(L'*L))*framesAveraged; % Estimation/smoothing

% detrendedFrames = detrend(framesAveraged);
% plot(detrendedFrames, 'b');

% Normalize over R, G, B channelsstd
meanValue = mean(detrendedFrames, 1);
stdValue = std(detrendedFrames, [], 1);
normalizedFrames = bsxfun(@rdivide, bsxfun(@minus,detrendedFrames,meanValue), stdValue);

% Permuate data so that the dimension matches sources x samples
normalizedFrames = permute(normalizedFrames, [2, 1]);

% Apply ICA to the normalized data; search for three sources
sources = jadeR(normalizedFrames, 3) * normalizedFrames;

% Permuate data so that the dimension matches smaples x sources
sources = permute(sources, [2, 1]);

% Find the source with the highest peak
[value, index] = max(sources(:));
[row, column] = ind2sub(size(sources), index);

% Apply FFT to the best source
channel = sources(:, column);
%sourceAfterFFT = fft(channel);
%sourceAfterFFT = permute(sourceAfterFFT, [2, 1]);

% Smooth the signal ing a five-point moving average filter
windowSize = 5;
b = (1/windowSize)*ones(1,windowSize);
smoothedSignal = filter(1, b, channel);

% Hamming window smoothening
bandPassFilter = fir1(128, [0.07 0.4]);
hummingChannel = filter(bandPassFilter, 1, smoothedSignal);

% Spline cubic function data interpolation
% resampledData = resample(hummingChannel,1:256, 'spline');
Tx = 1:size(hummingChannel, 1);
desiredSampling = 256;
[resampledData, TResampledData] = resample(hummingChannel, Tx, desiredSampling, 3, 1, 'spline');

% figure, plot(TResampledData, resampledData,  'r');
% fftResult = fft(resampledData);
% plot(abs(fftResult), 'r');

% Lomb periodogram PSD
[pxx,f] = plomb(hummingChannel,Tx);
% figure, plot(f, pxx, 'b');

rr = 15;