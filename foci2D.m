function foci2D
%% Adam Tyson | 2018-05-03 | adam.tyson@icr.ac.uk
% loads an .lsm file, segments the first channel (nuclear), and estimates
% cell boundaries
% measures channel 2 on a per cell basis

%% TO DO

vars=getVars;
tic
cd(vars.directory)

files=dir('*.lsm'); % all tif's in this folder
numImages=length(files);
imCount=0;

f = waitbar(0,'1','Name','Analysing images...');
for file=files' % go through all images
    imCount=imCount+1;
    waitbar((imCount-1)/numImages,f,strcat("Analysing Image: ", num2str(imCount)))
    
    rawFile{imCount}=file.name;
    disp(['Processing - ' rawFile{imCount}])
    
    % load - evalc to supress bf output
    evalc('[data, ~, ~]=lsmPrep2chan(rawFile{imCount})');
    ch1Max=max(data.channel1,[],3);
    ch2Max=max(data.channel2,[],3);
    
    % segment
    imFilt = imgaussfilt(ch1Max,vars.filtSigmaCh1);

    minSig = min(imFilt(:));
    maxSig = max(imFilt(:));
    imNorm = (imFilt - minSig) / (maxSig - minSig);

    levelOtsu = graythresh(imNorm);
    bwCh1 = im2bw(imNorm,levelOtsu);
    bwCh1=~(bwareaopen(~bwCh1, vars.holeFill)); % FILL HOLES
    bwCh1=bwareaopen(bwCh1,vars.noiseRem); % remove small objs

    
    % get borders
    labelDAPI = bwlabel(bwCh1);
    D = bwdist(bwCh1);
    DL = watershed(D);
    cellBorders = DL == 0;
    labelCell = bwlabel(~cellBorders);
    labelCell=labelCell; 
    
    if strcmp(vars.plot, 'Yes')
        figure; 
        imagesc(labelCell+labelDAPI),...
            title(['Segmented Cells - ' rawFile{imCount}])
    end
    
    % measure other channel
    [areaColoc{imCount}, intenColoc{imCount}, numFoci{imCount}] = ...
    fociPerCell(ch2Max, labelCell, labelDAPI, vars, rawFile{imCount});
                                                                                   
end
delete(f)
toc
end

%% Internal functions
function vars=getVars
vars.directory = uigetdir('', 'Choose directory containing images');

vars.plot = questdlg('Display results? ', ...
    'Plotting', ...
    'Yes', 'No', 'No');

prompt = {'Largest hole to fill:',...
    'Smoothing sigma (nucleus):',...
    'Smoothing sigma (foci):',...
    'Largest object to remove:'};

dlg_title = 'Analysis variables';
num_lines = 1;
defaultans = {'500', '5', '1', '1000'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
vars.holeFill=str2double(answer{1});% largest hole to fill
vars.filtSigmaCh1=str2double(answer{2});% smoothing kernel
vars.filtSigmaCh2=str2double(answer{3});% smoothing kernel
vars.noiseRem=str2double(answer{4}); % smallest obj to remove

end