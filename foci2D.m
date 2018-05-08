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
    waitbar((imCount-1)/numImages,f,strcat("Analysing Image: ",...
                                            num2str(imCount)))
    
    rawFile{imCount}=file.name;
    disp(['Processing - ' rawFile{imCount}])
    
    % load - evalc to supress bf output
    evalc('[data, ~, ~]=lsmPrep2chan(rawFile{imCount})');
    ch1Max=max(data.channel1,[],3);
    ch2Max=max(data.channel2,[],3);
    
    % segment nuclei and find edges
    [labelDAPI, labelCell] = nucSegBorders(ch1Max, vars);
    
    % measure other channel
    [areaColoc{imCount}, intenColoc{imCount}, numFoci{imCount}] = ...
    fociPerCell(ch2Max, labelCell, labelDAPI, vars, rawFile{imCount});
    % save results
end

if strcmp(vars.save, 'Yes')
   save_raw_res(rawFile, numFoci, intenColoc, areaColoc, imCount, vars) 
end

delete(f)
toc
end

%% Internal functions

function save_raw_res(rawFile, numFoci, intenColoc,...
                        areaColoc, imCount, vars)
% tidy up

for i=1:imCount
lengths(i)=length(numFoci{i});
end
numFociReshape=NaN(imCount+1, max(lengths)+1);
intenColocReshape=numFociReshape;
areaColocReshape=numFociReshape;

for i=1:imCount
numFociReshape(i+1,2:length(numFoci{i})+1)=numFoci{i};
intenColocReshape(i+1,2:length(intenColoc{i})+1)=intenColoc{i};
areaColocReshape(i+1,2:length(areaColoc{i})+1)=areaColoc{i};
end

numFociCell=num2cell(numFociReshape);
intenColocCell=num2cell(intenColocReshape);
areaColocCell=num2cell(areaColocReshape);

numFociCell{1,1}='Image';
intenColocCell{1,1}='Image';
areaColocCell{1,1}='Image';

for cellnum=1:max(lengths)
     numFociCell{1, cellnum+1}=strcat("Cell_", num2str(cellnum));
     intenColocCell{1, cellnum+1}=strcat("Cell_", num2str(cellnum));
     areaColocCell{1, cellnum+1}=strcat("Cell_", num2str(cellnum));
 end
 
for image=1:imCount
     numFociCell{image+1,1}=rawFile{image};
     intenColocCell{image+1,1}=rawFile{image};
     areaColocCell{image+1,1}=rawFile{image};
end

fociNum_Table=cell2table(numFociCell);
fociInten_Table=cell2table(intenColocCell);
fociArea_Table=cell2table(areaColocCell);

writetable(fociNum_Table, ['fociNumbers_' vars.stamp '.csv'],...
                            'WriteVariableNames', 0)
writetable(fociInten_Table, ['fociTotalInten_' vars.stamp '.csv'],...
                            'WriteVariableNames', 0)
writetable(fociArea_Table, ['fociTotalArea_' vars.stamp '.csv'],...
                            'WriteVariableNames', 0)                        
end

function vars=getVars
vars.directory = uigetdir('', 'Choose directory containing images');

vars.plot = questdlg('Display segmentation? ', ...
    'Plotting', ...
    'Yes', 'No', 'No');

vars.save = questdlg('Save results as .csv? ', ...
    'Saving', ...
    'Yes', 'No', 'Yes');

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

vars.stamp=num2str(fix(clock)); % date and time 
vars.stamp(vars.stamp==' ') = '';%remove spaces
end
