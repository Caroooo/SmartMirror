function results = process(input)
image = input;

image_to_show = face_detection(image);

results = image_to_show;