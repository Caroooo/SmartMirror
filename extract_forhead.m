function extract_forhead(input_name, output_name)

UL_CORNER_PROPORTIONS = [1/3, 0.07];
FH_WIDTH_PROPORTIONS = 1/3;
FH_HEIGHT_PROPORTIONS = 0.21;

DIMS = [300, 300];

UL_CORNER = round(DIMS .* UL_CORNER_PROPORTIONS);
FH_W = round(FH_WIDTH_PROPORTIONS * DIMS(1));
FH_H = round(FH_HEIGHT_PROPORTIONS * DIMS(2));

vi = VideoReader(input_name);
vo = VideoWriter(output_name, 'MPEG-4');
vo.FrameRate = 58;
open(vo);

faceHunter = Hunter('FrontalFaceCART', DIMS(1), DIMS(2), true);
i = 0;

while hasFrame(vi) && i < 1200
    im = readFrame(vi);
    face = faceHunter.hunt(im);
    
    if isempty(face)
        fprintf('face lost\n');
        face = zeros(DIMS(1), DIMS(2));
    end
    
    forehead(:,:,:) = face(UL_CORNER(2) : UL_CORNER(2) + FH_H,...
                          UL_CORNER(1) : UL_CORNER(1) + FH_W,:);
    writeVideo(vo, forehead);
    i = i + 1;
end

close(vo);

