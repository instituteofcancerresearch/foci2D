% function foci2D
%% Adam Tyson | 2018-05-03 | adam.tyson@icr.ac.uk
% loads an .lsm file, segments the first channel (nuclear), and estimates
% cell boundaries
% measures channel 2 on a per cell basis

%% TO DO
% meaure channel2 per cell

vars=getVars;
tic
cd(vars.directory)

files=dir('*.lsm'); % all tif's in this folder
numImages=length(files);
imCount=0;
for file=files' % go through all images
    imCount=imCount+1;
    rawFile{imCount}=file.name;

    % load
    [data, voxSize, ~]=lsmPrep2chan(rawFile{imCount});
    data.channel1Max=max(data.channel1,[],3);
    data.channel2Max=max(data.channel2,[],3);

    % segment
    imageFiltered = imgaussfilt(data.channel1Max,vars.filtSigma);

    minSignal = min(imageFiltered(:));
    maxSignal = max(imageFiltered(:));
    imageDilatedNorm = (imageFiltered - minSignal) / (maxSignal - minSignal);

    levelOtsu = graythresh(imageDilatedNorm);
    bwCh1 = im2bw(imageDilatedNorm,levelOtsu);
    bwCh1=~(bwareaopen(~bwCh1, vars.holeFill));
    
    % get borders
    labelDAPI = bwlabel(bwCh1);
    D = bwdist(bwCh1);
    DL = watershed(D);
    cellBorders = DL == 0;
    labelCell = bwlabel(~cellBorders);

    if strcmp(vars.plot, 'Yes')
        figure; imagesc(labelCell+labelDAPI), title(['Segmented Cells - ' rawFile{imCount}])
    end
end
toc
% end

%% Internal functions
function vars=getVars
vars.directory = uigetdir('', 'Choose directory containing images');

vars.plot = questdlg('Display results? ', ...
    'Plotting', ...
    'Yes', 'No', 'No');

prompt = {'Largest hole to fill:',...
    'Smoothing sigma:'};

dlg_title = 'Analysis variables';
num_lines = 1;
defaultans = {'500', '5'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
vars.holeFill=str2double(answer{1});% largest hole to fill
vars.filtSigma=str2double(answer{2});% smoothing kernel
end