function foci2D
%% Adam Tyson | 2018-05-03 | adam.tyson@icr.ac.uk
% loads an .lsm file, segments the first channel (nuclear), and estimates
% cell boundaries
% measures channel 2 on a per cell basis

%% TO DO
% save output
% normalise output

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

    levelOtsu = vars.threshScaleCh1*graythresh(imNorm);
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

prompt = {'Nuclear segmentation threshold (a.u.):',...
    'Foci segmentation threshold (a.u.)::',...
    'Largest hole to fill:',...
    'Largest object to remove:',...
    'Smoothing sigma (nucleus):',...
    'Smoothing sigma (foci):'};

dlg_title = 'Analysis variables';
num_lines = 1;
defaultans = {'1','1','500','1000', '5', '1'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
vars.threshScaleCh1=str2double(answer{1});%change sensitivity of threshold
vars.threshScaleCh2=str2double(answer{2});%change sensitivity of threshold
vars.holeFill=str2double(answer{3});% largest hole to fill
vars.noiseRem=str2double(answer{4}); % smallest obj to remove
vars.filtSigmaCh1=str2double(answer{5});% smoothing kernel
vars.filtSigmaCh2=str2double(answer{6});% smoothing kernel

end