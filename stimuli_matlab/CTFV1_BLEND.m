%% alpha blending the stimuli in the white noise
% one way (as close as what xpman program does):
% a weighted sum of the luminance values of each pixel of the image
% and the background. 

close all; clear; clc

basefolder = 'C:/Users/Adminuser/Documents/03_SFmasking/Experiment/stimuli_matlab/';
outfolder_stim = [basefolder 'stimuli/'];
outfolder_back = [basefolder 'background/'];
load([basefolder 'CTFV1_STIM.mat'])
addpath(basefolder)

backgrounds = 8;

outputmat = 'CTFV1_BLEND.mat';

%%%%%%%%%%%% load this blurry mask
%%%%%%%%%%%% make sure the face is just as big as the stimuli
[MaskIm,~,MaskAlpha] = (imread([basefolder 'blurrymask.bnp']));
%MaskAlpha = single(MaskAlpha);

MaskAlpha = padarray(MaskAlpha,[round(paddims/2) round(paddims/2)],'replicate'); % pad to get the same dimensions as background image.
MaskAlpha = im_stimb(1:desired_size(1),1:(desired_size));


imshow(MaskAlpha)
imshow(1-MaskAlpha)

MaskAlpha = padarray(MaskAlpha,[round(paddims/2) round(paddims/2)],'replicate'); % pad to get the same dimensions as background image.
MaskAlpha = im_stimb(1:desired_size(1),1:(desired_size));

signalcontrast = 0.45;
alpha = 1-signalcontrast;
SNR = signalcontrast/alpha;
%LC = [0.45 0.1]; % desired luminance and contrast

stimuli = {'Stim' 'MaskLSF' 'MaskHSF'}; %stimuli and mask

%preallocate for speed
finalstim_backpixLC = cell(backgrounds,length(stimuli)); %preallocate
finalstim_facepixLC = cell(backgrounds,length(stimuli)); %preallocate
finalbackim_backpixLC = cell(backgrounds,length(stimuli)); %preallocate
finalbackim_facepixLC = cell(backgrounds,length(stimuli)); %preallocate

for theback = 1:backgrounds % for all scrambled backgrounds
    fprintf('bleding and safing images for %d background \n',theback)
    if theback < 10
        backname = ['BG0' num2str(theback)];
    else
        backname = ['BG' num2str(theback)];
    end

    for thestim = 1:length(stimuli) %stim, maskLSF, maskHSF
        %naming for checking and saving
        stimulus  = char(stimuli(thestim)) ;
        if thestim == 1
            set = imset.eq_stim;
        elseif thestim == 2 %Mask LSF
            set = imset.mask(thestim-1,:);
        elseif thestim == 3 %Mask HSF 
            set = imset.mask(thestim-1,:);
        end
        for theface = 1:length(nim) %for all faces
            backim = imset.iter_back{theback};
            %imshow(backim)
            fprintf('mean: %f - std: %f - back %d\n',mean2(backim),std2(backim),theback) % check contr and lum for the background
            backim = backim*alpha;

            signalim = set{theface};

            signalim = signalim*signalcontrast;
            signalim =  (signalim.*(1-MaskAlpha) ) + (backim.* (MaskAlpha));			
            blendim = signalim;

            %imshow(blendim)
            blendim = blendim - mean2(blendim); %normalize blend stim part 1
            blendim = blendim / std2(blendim); %normalize blend stim part 2
            blendim	= (blendim*LC(2)) + LC(1); %desired lum and contrast
            fprintf('mean: %f - std: %f - face %d for type: %s %s blendedddd\n',mean2(blendim),std2(blendim),theface,stimtype,stimulus) % check contr and lum for the background

            % replace background pixels of the blend image by the original ones
            backim = imset.iter_back{theback};
            blendim(backpixindex) = backim(backpixindex);
            imshow(blendim); 

            imset.blendim{theback,thestim,theface} = blendim;     	

            finalstim_backpixLC{theback,thestim}(theface,:) = [mean(blendim(backpixindex)) std(blendim(backpixindex))]; %%%% $$$$$$
            finalstim_facepixLC{theback,thestim}(theface,:) = [mean(blendim(facepixindex)) std(blendim(facepixindex))]; %%%% $$$$$$

            % saving the stimuli with correct naming
            if theface < 10
                facenum = ['0' num2str(theface)];
            else
                facenum = num2str(theface);
            end                

            name = [backname '_' stimulus '_' facenum];

            imwrite(blendim,[outfolder_stim name '.bmp'],'BMP')

        end
        backim = imset.iter_back{theback};
        imshow(backim); 
        finalbackim_backpixLC{theback,thestim} = [mean(backim(backpixindex)) std(backim(backpixindex))]; %%%% $$$$$$
        finalbackim_facepixLC{theback,thestim} = [mean(backim(facepixindex)) std(backim(facepixindex))] ;%%%% $$$$$$

        imwrite(backim,[outfolder_back backname '.bmp'],'BMP')
    end
end




%%

disp('saving..')
save([basefolder outputmat],'-v7.3')


