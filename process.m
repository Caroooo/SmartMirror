function results = process(input)

% States for signaling do_output function
global NO_DETECTION NO_REFRESH REFRESH;

% When did the system start working
global start_time;

% States for this function
NO_FACE = 0;
FACE_DETECTED = 1;

% Configuration
BUFFER_SIZE = 400;
REFRESH_PERIOD  = 2;
RESPIRATION_RATE_WINDOW = 8;
HEARTBEAT_WINDOW = 6;
BLOOD_PRESSURE_WINDOW = 10;

% Default data for do_output
results.person_name = 'No Face Detected';
results.hb = '-';
results.bp = '-';
results.rr = '-';
results.state = '';

% Circular buffer for recording frames
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

% Try to detect or track face
face = face_detection(image);

% State machine with two states: NO_FACE and FACE_DETECTED
if state == NO_FACE
     
    if isempty(face) 
        % If no face is detected, abort everything
        
        results.state = NO_DETECTION;
        next_state = NO_FACE;
        counter = 1;  
    else
        % If a face is detected, recognize it and start measuring
        
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
    
    if isempty(face)    
        % If no face is detected, abort and reset everything
        
        results.state = NO_DETECTION;
        next_state = NO_FACE;
        results.state = NO_REFRESH;
        counter = 1;
    else
        % If the face is successfully tracked, add it to the buffer
        
        results.person_name = person_name;
        results.hb = 'Measuring...';
        results.bp = 'Measuring...';
        results.rr = 'Measuring...';
        
        % Create a new struct with image and time label
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

            % Straighten the circular buffer so it is not circular anymore.
            % Technically this is not needed and should be removed
            % at some point to optimize a bit.
            tmp = [buffer(counter:end) buffer(1:counter-1)];

            % Call Respiration Rate
            if current_time - detection_time >= RESPIRATION_RATE_WINDOW + 2
                start_index = find(my_extractfield(tmp, 'time') <= ...
                               current_time - RESPIRATION_RATE_WINDOW, 1, 'last');                   
                rr = dummy_respiration(tmp(start_index:end));
                % Here we can call Shankar's functions for logging
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
            
            % Since it is refresh period, signal do_output that it
            % should refresh the output as well            
            results.state = REFRESH;
        else
            % If it is not refresh period, signal do_output that
            % nothing has to be changed
            results.state = NO_REFRESH;
        end
                
        next_state = FACE_DETECTED;
    end
end

% fprintf('state = %d next_state = %d res.state = %d,\n',...
%         state, next_state, results.state);

state = next_state;