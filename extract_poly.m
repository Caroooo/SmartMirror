function extracted_image = extract_poly(image, polyXArray, polyYArray, do_rotate)

maxX = max(polyXArray);
maxY = max(polyYArray);
minX = min(polyXArray);
minY = min(polyYArray);

w = maxX-minX;
h = maxY-minY;

cropped = imcrop(image, [minX, minY, w, h]);

if do_rotate
    
    x = polyXArray;
    y = polyYArray;

    x_diff = x(4) - x(3);
    y_diff = y(4) - y(3);

    angle = atan(y_diff/x_diff) * 180 / pi;

    if y(2) > y(3)
        angle = angle + 180;
    end

    extracted_image = imrotate(cropped,angle);

    alpha = atan(abs((y(2) - y(1)))/abs((x(2) - x(1))));
    offset = cos(alpha) * abs(x(1) - x(4));
    side = sqrt((y(2) - y(1))^2 + (x(2) - x(1))^2);
    %extracted_image = insertMarker(extracted_image, [offset offset], 'circle');

    extracted_image = imcrop(extracted_image, [offset offset side side]);
else
    extracted_image = cropped;
end