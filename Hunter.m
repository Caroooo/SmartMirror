classdef Hunter < handle
    
    properties
        objectDetector;
        pointTracker ;
        numPts = 0;
        frameCount = 0;
        oldPoints = 0;
        bboxPoints = 0;
        width;
        height;
        doRotate;
        % Setup
        CRITICAL_POINT_NUM = 10;
        SOFT_POINT_NUM = 60;
        RECHECK_RATE = 30;
        RESCALE_METHOD = 'bilinear';
    end
    
    methods
        
        function obj = Hunter(detectorString , detectorWidth, detectorHeight, doRotate)
            obj.objectDetector = vision.CascadeObjectDetector(detectorString);
            obj.pointTracker = vision.PointTracker('MaxBidirectionalError', 2);
            obj.width = detectorWidth;
            obj.height = detectorHeight;
            obj.doRotate = doRotate;
        end
    
        function object = hunt(o, image)
            myPoly = 0;
            imageGray = rgb2gray(image);
            o.frameCount = o.frameCount + 1;


            if o.numPts < o.CRITICAL_POINT_NUM
                % If not enough points, detect object again

                [success, o.numPts, o.oldPoints, o.bboxPoints] = ...
                    detect(imageGray, o.objectDetector, o.pointTracker);
                if success
                    initialize(o.pointTracker, o.oldPoints, imageGray);
                    [image, myPoly] = draw_stuff(image, o.bboxPoints, o.oldPoints);
                end

            else
                % If there are enough points, usually try just tracking
                do_tracking = 1;

                % Maybe check detection again if number of points
                % dropped below some soft cap
                if (mod(o.frameCount, o.RECHECK_RATE) == 0)&&(o.numPts < o.SOFT_POINT_NUM)
                    [success, tnumPts, toldPoints, tbboxPoints] = ...
                        detect(imageGray, o.objectDetector, o.pointTracker);

                    % If new detection is good, reset tracking
                    if success && tnumPts > o.numPts
                        do_tracking = 0;

                        o.numPts = tnumPts;
                        o.oldPoints = toldPoints;
                        o.bboxPoints = tbboxPoints;
                        
                        initialize(o.pointTracker, o.oldPoints, imageGray);
                        
                        [image, myPoly] = draw_stuff(image, o.bboxPoints...
                            , o.oldPoints);
                    end
                end

                if do_tracking == 1
                    % Track the face
                    [visiblePoints, oldInliers, o.numPts] = ...
                        track_object(o.pointTracker, imageGray, o.oldPoints);

                    % If track successful, calculate/draw things
                    if o.numPts >= 10

                        [o.bboxPoints, visiblePoints] = ...
                            find_transform(oldInliers, visiblePoints, o.bboxPoints);

                        [image, myPoly] = draw_stuff(image, o.bboxPoints...
                        , visiblePoints);

                        % Reset the points.
                        o.oldPoints = visiblePoints;
                        setPoints(o.pointTracker, o.oldPoints);
                    end
                end
            end


            if myPoly ~= 0
                % If a face is found, pass it 
                xses = double(myPoly(1:2:end));
                yses = double(myPoly(2:2:end));

                % Crop and rotate image
                cropped_object = extract_poly(image, xses, yses, o.doRotate);

                % Resize so it is always the same size
                object = imresize(cropped_object,...
                                [o.width o.height],o.RESCALE_METHOD);
            else
                % If not, pass a black image
                object = [];
            end
        end        
    end
end