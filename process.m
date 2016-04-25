function results = process(input)

global NO_DETECTION NO_REFRESH REFRESH;
global start_time;
% States for this function
NO_FACE = 0;
FACE_DETECTED = 1;

BUFFER_SIZE = 400;
REFRESH_PERIOD  = 2;
RESPIRATION_RATE_WINDOW = 8;
HEARTBEAT_WINDOW = 6;
BLOOD_PRESSURE_WINDOW = 10;

results.person_name = 'No Face Detected';
results.hb = '-';
results.bp = '-';
results.rr = '-';
results.state = '';

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
    last_refresh = etime(clock, start_time);
end

persistent state;
if isempty(state)
    state = NO_FACE;
end

persistent person_name;
if isempty(person_name)
    person_name = '';
end

persistent detection_time;
if isempty(detection_time)
    detection_time = etime(clock, start_time);
end

% The input is image from camera
image = input;
face = face_detection(image);
current_time = -1;

if state == NO_FACE
     
    % If no face is detected, abort everything
    if isempty(face)        
        results.state = NO_DETECTION;
        next_state = NO_FACE;
        counter = 1;
        
    % If a face is detected, recognize it and start measuring
    else
        
        % DUMMY FACE RECOGNITION, add real one later
        person_name = 'Darth Vader';
        results.person_name = person_name;
        
        % It shold be clear that other parameters are being measured
        results.hb = 'Measuring...';
        results.bp = 'Measuring...';
        results.rr = 'Measuring...';
        results.state = REFRESH;
        next_state = FACE_DETECTED;
        
        % Set time of detection. This is used later to know
        % if sufficient time has passed for each parameter to try 
        % measuring it
        detection_time = etime(clock, start_time);
        
        % Reset last refresh so the refresh period will begin
        % counting from zero
        last_refresh = etime(clock, start_time);
    end

elseif state == FACE_DETECTED
    
    % If no face is detected, abort everything
    if isempty(face)        
        results.state = NO_DETECTION;
        next_state = NO_FACE;
        results.state = NO_REFRESH;
        counter = 1;
    else
        
        results.person_name = person_name;
        results.hb = 'Measuring...';
        results.bp = 'Measuring...';
        results.rr = 'Measuring...';
        
        % Create a new struct with image and time
        frame = create_frame_object(face);

        % Add new object to circular buffer
        buffer(counter) = frame;
        counter = counter + 1;
        if counter == BUFFER_SIZE + 1
            counter = 1;
        end

        % If the time is right, call modules
        % Generally speaking, this is every REFRESH_PERIOD seconds
        current_time = etime(clock, start_time);

        if (current_time - last_refresh >= REFRESH_PERIOD)

            % **********Call modules***************

            % Straighten the circular buffer so it is not circular anymore
            tmp = [buffer(counter:end) buffer(1:counter-1)];

            % Call Respiration Rate
            if current_time - detection_time >= RESPIRATION_RATE_WINDOW + 2
                start_index = find(my_extractfield(tmp, 'time') <= ...
                               current_time - RESPIRATION_RATE_WINDOW, 1, 'last');                   
                rr = dummy_respiration(tmp(start_index:end));
                results.rr = strcat(num2str(rr), ' rcpm');
            end

            % Call Heartbeat
            if current_time - detection_time >= HEARTBEAT_WINDOW + 2
                start_index = find(my_extractfield(tmp, 'time') <= ...
                                   current_time - HEARTBEAT_WINDOW, 1, 'last');                   
                hb =  dummy_hb(tmp(start_index:end));
                results.hb = strcat(num2str(hb), ' bpm');
            end

            % Call Blood Pressure
            if current_time - detection_time >= BLOOD_PRESSURE_WINDOW + 2
                start_index = find(my_extractfield(tmp, 'time') <= ...
                              current_time - BLOOD_PRESSURE_WINDOW, 1, 'last');                   
                [bps, bpd] = dummy_bp(tmp(start_index:end));
                results.bp = strcat(num2str(bps), '/', num2str(bpd), ' mmHg');
            end

            last_refresh = etime(clock, start_time);
            results.state = REFRESH;
        else
            results.state = NO_REFRESH;
        end
                
        next_state = FACE_DETECTED;
    end
end
% fprintf('state = %d next_state = %d res.state = %d, ct = %2.2f, dt = %2.2f\n', state, next_state, results.state, current_time, detection_time);
state = next_state;