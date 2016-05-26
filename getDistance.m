function [location1,location2] = getDistance(peaks, locations)
if length(peaks) == 2
    location1 = locations(1);
    location2 = locations(2);
else if length(peaks) < 2
        location1 = 0;
        location2 = 0;
    else
        [temp, ind] = sort(peaks,'descend');
%         distance = abs(locations(ind(1)) - locations(ind(2)));
        location1 = locations(ind(1));
        location2 = locations(ind(end));
    end
end