function results = process(input)

% States for signaling do_output function
global NO_DETECTION NO_REFRESH REFRESH;

% When did the system start working
global start_time;

% States for this function
NO_FACE = 0;
FACE_DETECTED = 1;

% Configuration
REFRESH_PERIOD  = 20;
RESPIRATION_RATE_WINDOW = 30;
HEARTBEAT_WINDOW = 6;
BLOOD_PRESSURE_WINDOW = 20;

% Default data for do_output
results.person_name = 'No Face Detected';
results.hb = '-';
results.bp = '-';
results.rr = '-';
results.state = '';

% Circular buffer for recording faces
persistent bufferFace;
if isempty(bufferFace)
   bufferFace = Buffer;
end

% Circular buffer for recording eyes
persistent bufferEyes;
if isempty(bufferEyes)
    bufferEyes = Buffer;
end

% Circular buffer for recording hand
persistent bufferHand;
if isempty(bufferHand)
    bufferHand = Buffer;
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

% Create the hunters object.
persistent faceHunter ;
if isempty(faceHunter)
    faceHunter = Hunter('FrontalFaceCART', 300, 300, true);
end

persistent eyesHunter ;
if isempty(eyesHunter)
    eyesHunter = Hunter('eyePairBig',40, 200, false);
end

persistent handHunter ; 
if isempty(handHunter)
    handHunter = Hunter('hands_final.xml', 200, 200 , true);
end

persistent eyes_found;
if isempty(eyes_found)
    eyes_found = false;
end

persistent hand_found;
if isempty(hand_found)
    hand_found = false;
end

% Detect and track face
face = faceHunter.hunt(input);

% State machine with two states: NO_FACE and FACE_DETECTED
if state == NO_FACE
     
    if isempty(face) 
        % If no face is detected, abort everything
        results.state = NO_DETECTION;
        next_state = NO_FACE;
    else
        % If a face is detected, recognize it and start measuring
        
        % DUMMY FACE RECOGNITION, add real one later
        person_name = 'Darth Vader';
        results.person_name = person_name;
        
        % Detect and track eyes and hand
        hand = handHunter.hunt(input);       
        eyes = eyesHunter.hunt(face);
        
        % If eyes/hand are found, set corresponding variables
        hand_found = ~isempty(hand);
        eyes_found = ~isempty(eyes);
        
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
        bufferFace.reset();
        bufferEyes.reset();
        bufferHand.reset();
    else   
       
        results.person_name = person_name;
        results.hb = 'Measuring...';
        results.bp = 'Measuring...';
        results.rr = 'Measuring...';
        
        % If the time is right, call modules
        % Generally speaking, this is every REFRESH_PERIOD seconds
        current_time = etime(clock, start_time);
        
        % Add new face to buffer
        bufferFace.add_frame(face, current_time);
        
        % Eyes detection
        eyes = eyesHunter.hunt(face); 
        if eyes_found  
            if isempty(eyes)
                eyes_found = false;
                bufferEyes.reset();
            else
                bufferEyes.add_frame(eyes, current_time);
            end
        else
            if ~isempty(eyes)
                eyes_found = true;
            end
        end
            
                
        % Hand detection
        hand = handHunter.hunt(input); 
        if hand_found  
            if isempty(hand)
                hand_found = false;
                bufferHand.reset();
            else
                bufferHand.add_frame(hand, current_time);
            end
        else
            if ~isempty(hand)
                hand_found = true;
            end
        end                
                
        if (current_time - last_refresh >= REFRESH_PERIOD)

            % **********Call modules***************
            % Call Respiration Rate
            if bufferFace.get_record_duration() >= RESPIRATION_RATE_WINDOW + 2
                [faces, times] = bufferFace.get_last_seconds(RESPIRATION_RATE_WINDOW);
                rr = dummy_respiration(faces, times);
                % Here we can call Shankar's functions for logging
                results.rr = strcat(num2str(rr), ' rcpm');
            end

            % Call Heartbeat
            if bufferFace.get_record_duration() >= HEARTBEAT_WINDOW + 2                  
                hb =  dummy_hb(bufferFace.get_last_seconds...
                                    (HEARTBEAT_WINDOW));
                results.hb = strcat(num2str(hb), ' bpm');
            end
            
            if ~hand_found
                results.bp = ('HAND NOT FOUND!');
            else
                % Call Blood Pressure
                if bufferHand.get_record_duration() >= BLOOD_PRESSURE_WINDOW + 2  
                    [faces, times] = bufferFace.get_last_seconds(BLOOD_PRESSURE_WINDOW);
                    [bps, bpd] = dummy_bp(faces,...
                                          bufferHand.get_last_seconds(BLOOD_PRESSURE_WINDOW),...
                                          times);
                    results.bp = strcat(num2str(bps), '/', num2str(bpd), ' mmHg');
                end
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
% fprintf('%d\n', bufferFace.first_empty);
state = next_state;