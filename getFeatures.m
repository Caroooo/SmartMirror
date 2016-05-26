function features = getFeatures(leftEyeDistances, leftEyeThreshold,...
                                rightEyeDistances, rightEyeThreshold)
% Features are : PERCLOS(PERcentage of eyelid CLOSure), 
% Blink Frequency (BF), Maximum Close Duration (MCD), Average Opening
% Level (AOL), Opening Velocity (OV), and Closing Velocity (CV)

features = struct('PERCLOS',[],'MCD',[],'BF',[],'AOL',[],'OV',[],'CV',[]);

period = length(leftEyeDistances);
% Calculating PERCLOS for both eyes
[leftEyeClosed, leftCT] = find(leftEyeDistances < leftEyeThreshold);
[rightEyeClosed, rightCT] = find(rightEyeDistances < rightEyeThreshold);

features.PERCLOS.leftEye = length(leftEyeClosed)/period;
features.PERCLOS.rightEye = length(rightEyeClosed)/period;

% Calculating MCD for both eyes
features.MCD.leftEye = 0;
features.MCD.rightEye = 0;
summary = 1;
for i = 2:length(leftEyeClosed)
    if leftCT(i) == (leftCT(i - 1) + 1)
        summary = summary + 1;
    else
        if features.MCD.leftEye < summary
            features.MCD.leftEye = summary;
        end
        summary = 1;
    end
    if i == length(leftEyeClosed)
        if features.MCD.leftEye < summary
            features.MCD.leftEye = summary;
        end
        summary = 1;
    end
end

for i = 2:length(rightEyeClosed)
    if rightCT(i) == (rightCT(i - 1) + 1)
        summary = summary + 1;
    else
        if features.MCD.rightEye < summary
            features.MCD.rightEye = summary;
        end
        summary = 1;
    end
    if i == length(rightEyeClosed)
        if features.MCD.rightEye < summary
            features.MCD.rightEye = summary;
        end
        summary = 1;
    end
end

% Calculating BF for both eyes
[pksLeft,locsLeft] = findpeaks(-leftEyeDistances, 'MinPeakHeight',...
                               -leftEyeThreshold);
[pksRight,locsRight] = findpeaks(-rightEyeDistances, 'MinPeakHeight',...
                                 -rightEyeThreshold);
                             
features.BF.leftEye = length(pksLeft)/period;
features.BF.rightEye = length(pksRight)/period;

% Calculating OV and CV for both eyes
% Left eye
features.OV.leftEye = 0;
features.CV.leftEye = 0;
sumClosing = 0;
sumOpening = 0;
[pks, locs] = findpeaks(leftEyeDistances);
locations = sort([locs,locsLeft]);

for i = 1 : length(locations) - 1
   if any(locs == locations(i))
       opened = 1;
   else
       opened = 0;
   end
   
   if any(locs == locations(i + 1))
       if opened 
           state = 0;
       else
           state = 1;
       end
   else
       if opened
           state = -1;
       else
           state = 0;
       end
   end
   
   if state == -1
       features.CV.leftEye = features.CV.leftEye +... 
       abs(leftEyeDistances(locations(i))...
       - leftEyeDistances(locations(i + 1)))/abs(locations(i)...
       - locations(i + 1));% pixels/frame
       sumClosing = sumClosing + 1;
   else if state == 1
           features.OV.leftEye = features.OV.leftEye +...
           abs(leftEyeDistances(locations(i))...
           - leftEyeDistances(locations(i + 1)))/abs(locations(i)...
           - locations(i + 1));% pixels/frame
           sumOpening = sumOpening + 1;
       end
   end
end
features.CV.leftEye = features.CV.leftEye/sumClosing;
features.OV.leftEye = features.OV.leftEye/sumOpening;

% Right eye
features.OV.rightEye = 0;
features.CV.rightEye = 0;
sumClosing = 0;
sumOpening = 0;
[pks, locs] = findpeaks(rightEyeDistances);
locations = sort([locs,locsRight]);

for i = 1 : length(locations) - 1
   if any(locs == locations(i))
       opened = 1;
   else
       opened = 0;
   end
   
   if any(locs == locations(i + 1))
       if opened 
           state = 0;
       else
           state = 1;
       end
   else
       if opened
           state = -1;
       else
           state = 0;
       end
   end
   
   if state == -1
       features.CV.rightEye = features.CV.rightEye +...
       abs(rightEyeDistances(locations(i))...
       - rightEyeDistances(locations(i + 1)))/abs(locations(i)...
       - locations(i + 1));% pixels/frame
       sumClosing = sumClosing + 1;
   else if state == 1
           features.OV.rightEye = features.OV.rightEye +...
           abs(rightEyeDistances(locations(i))...
           - rightEyeDistances(locations(i + 1)))/abs(locations(i)...
           - locations(i + 1));% pixels/frame
           sumOpening = sumOpening + 1;
       end
   end
end
features.CV.rightEye = features.CV.rightEye/sumClosing;
features.OV.rightEye = features.OV.rightEye/sumOpening;

% Calculating AOL for both eyes
features.AOL.leftEye = 0;
features.AOL.rightEye = 0;
