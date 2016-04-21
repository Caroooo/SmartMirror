function rotim = rotate_image(image, orientation)
rotim = imrotate(image,orientation/pi*180 - 90,'nearest', 'crop');
 figure,imshow(rotim);
cropsze = fix(size(image,1)/sqrt(2));
offset = fix((size(image,1)-cropsze)/2);
rotim = rotim(offset:offset+cropsze, offset:offset+cropsze);
  figure,imshow(rotim);