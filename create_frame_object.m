function frame = create_frame_object(face)

global start_time;

frame.image(:,:,1) = face(:,:,1);
frame.image(:,:,2) = face(:,:,2);
frame.image(:,:,3) = face(:,:,3);
frame.time = etime(clock, start_time);