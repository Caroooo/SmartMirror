function extracted_image = extract_poly(image, polyXArray, polyYArray)

maxX = max(polyXArray);
maxY = max(polyYArray);
minX = min(polyXArray);
minY = min(polyYArray);

w = maxX-minX;
h = maxY-minY;

%cropped = insertShape(image, 'Rectangle', [minX, minY, w, h], 'Color', 'blue');
cropped = imcrop(image, [minX, minY, w, h]);

x = polyXArray;
y = polyYArray;


x_diff = x(4) - x(3);
y_diff = y(4) - y(3);

angle = atan(y_diff/x_diff) * 180 / pi;

if y(2) > y(3)
    angle = angle + 180;
end

% fprintf('xdiff = %.1f, ydiff = %.1f, angle = %.2f\n', x_diff, y_diff, angle);

extracted_image = imrotate(cropped,angle);

alpha = atan(abs((y(2) - y(1)))/abs((x(2) - x(1))));
offset = cos(alpha) * abs(x(1) - x(4));
side = sqrt((y(2) - y(1))^2 + (x(2) - x(1))^2);
% extracted_image = insertMarker(extracted_image, [offset offset], 'circle');

extracted_image = imcrop(extracted_image, [offset offset side side]);