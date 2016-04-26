classdef Buffer < handle
    
    properties
        first_empty = 1;
        images = uint8([]);
        time_stamps = [];
        MAX_BUFFER_SIZE = 400;
    end
    
    methods
        function add_frame(o,image, time_stamp)
            
            % Add data
            o.images(:,:,:,o.first_empty) = image;
            o.time_stamps(o.first_empty) = time_stamp;
            
            % Increase counter
            o.first_empty = o.first_empty + 1;
            if o.first_empty == o.MAX_BUFFER_SIZE + 1
                o.first_empty = 1;
            end
        end
        
        function reset(o)
            o.first_empty = 1;
            o.images = [];
            o.time_stamps = [];
        end
        
        function [images_out, time_stamps_out] = get_last_seconds(o,current_time, window)
            temp = [o.time_stamps(o.first_empty:end) o.time_stamps(1:o.first_empty-1)];
            start_index = find(temp <= current_time - window, 1, 'last');
            time_stamps_out = temp(start_index:end);
            new_index = mod((start_index + o.first_empty - 2),o.MAX_BUFFER_SIZE) +1;
            if new_index < start_index
                images_out = o.images(:,:,:,new_index : o.first_empty-1);
            else
                images_out = [o.images(:,:,:,new_index : end) o.images(:,:,:,1:o.first_empty-1)];
            end           
        end
    end
end