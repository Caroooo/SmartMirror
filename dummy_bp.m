function [bps, bpd] = dummy_bp(faceVideo, handVideo, timeStamps)
    bps = 120;
    bpd = 80;
    
    branko.faceVideo = faceVideo;
    branko.handVideo = handVideo;
    branko.timeStamps = timeStamps;
    save_video(faceVideo, 'VukanLice.avi');
    save_video(handVideo, 'VukanHand.avi');
    fprintf('Gotovooooooooo.../n');
    % save('branko.snimak', 'branko');
end