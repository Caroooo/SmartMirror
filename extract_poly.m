function extracted_image = extract_poly(image, polyXArray, polyYArray)

mask = poly2mask(polyXArray, polyYArray, size(image,1), size(image,2));


filtered(:,:,1) = image(:,:,1) .* uint8(mask);
filtered(:,:,2) = image(:,:,2) .* uint8(mask);
filtered(:,:,3) = image(:,:,3) .* uint8(mask);

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


[unused, minind] = sort(x);
[unused, maxind] = max(y(minind(1:2)));

lowLeftCornerInd = minind(maxind);
lowRightCornerInd = mod(lowLeftCornerInd -2, 4) + 1;


fprintf('%d   ', lowRightCornerInd);

x_diff = x(4) - x(3);
y_diff = y(4) - y(3);

angle = atan(y_diff/x_diff) * 180 / pi;

if y(2) > y(3)
    angle = angle + 180;
end

fprintf('xdiff = %.1f, ydiff = %.1f, angle = %.2f\n', x_diff, y_diff, angle);
extracted_image = imrotate(cropped,angle);