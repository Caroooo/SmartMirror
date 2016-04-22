function results = process(input)

RESCALE_SIZE = 300;
RESCALE_METHOD = 'bilinear';
BUFFER_SIZE = 400;
REFRESH_PERIOD  = 2;
RESPIRATION_RATE_WINDOW = 6;
HEARTBEAT_WINDOW = 5;
BLOOD_PRESSURE_WINDOW = 10;

results.person_name = 'No Face Detected';
results.hb = 0;
results.bps = 0;
results.bpd = 0;
results.rr = 0;

persistent buffer;

if isempty(buffer)
   buffer = struct('image', {}, 'time', {});
end

persistent counter;

if isempty(counter)
    counter = 1;
end

persistent last_refresh;
if isempty(last_refresh)
    last_refresh = toc;
end

% Process input image to extract normalized face
image = input;
cropped_face = face_detection(image);

if isempty(cropped_face)
    % TODO: Reset everything
    return
end

resized_face = imresize(cropped_face, [RESCALE_SIZE RESCALE_SIZE],...
                          RESCALE_METHOD);

% Create a new struct with image and time
frame.image(:,:,1) = resized_face(:,:,1);
frame.image(:,:,2) = resized_face(:,:,2);
frame.image(:,:,3) = resized_face(:,:,3);
frame.time = toc;

% Add new object to circular buffer
buffer(counter) = frame;
counter = counter + 1;
if counter == BUFFER_SIZE + 1
    counter = 1;
end

% If the time is right, call modules
current_time = toc;
% fprintf('ct = %.2f, lrf = %.2f, cnt = %d\n',...
%         current_time, last_refresh, counter);

if (current_time - last_refresh >= REFRESH_PERIOD)
    
    % **********Call modules***************
    
    % Straighten the circular buffer so it is not circular anymore
    tmp = [buffer(counter:end) buffer(1:counter-1)];
    
    % Call Respiration Rate
    if current_time >= RESPIRATION_RATE_WINDOW + 2
        start_index = find(extractfield(tmp, 'time') <= ...
                       current_time - RESPIRATION_RATE_WINDOW, 1, 'last');                   
        % respiration_rate(tmp(start_index:end));
    end
    
    % Call Heartbeat
    if current_time >= HEARTBEAT_WINDOW + 2
        start_index = find(extractfield(tmp, 'time') <= ...
                           current_time - HEARTBEAT_WINDOW, 1, 'last');                   
        % heartbeat(tmp(start_index:end));
    end
    
    % Call Blood Pressure
    if current_time >= BLOOD_PRESSURE_WINDOW + 2
        start_index = find(extractfield(tmp, 'time') <= ...
                      current_time - BLOOD_PRESSURE_WINDOW, 1, 'last');                   
        % blood_pressure(tmp(start_index:end));
    end
    
    last_refresh = toc;
end