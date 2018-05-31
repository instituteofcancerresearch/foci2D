function [areaColoc, intenColoc, numFoci] = fociPerCell(imCh2, ...
                                    labelCell, labelDAPI, vars, filename)
%% Adam Tyson | 2018-05-03 | adam.tyson@icr.ac.uk
% measures intensity, total area and number of foci per cell

% segment
imageFilt = imgaussfilt(imCh2,vars.filtSigmaCh2);

minSig = min(imageFilt(:));
maxSig = max(imageFilt(:));
imageDilNorm = (imageFilt - minSig) /(maxSig - minSig);

if strcmp(vars.threshQ, 'Yes')
    levelOtsu = vars.hardCodeFociThresh;
else
    levelOtsu = vars.threshScaleCh2*graythresh(imageDilNorm);
    disp(['Foci threshold - ' num2str(levelOtsu)])
end

bwCh2 = im2bw(imageDilNorm,levelOtsu);

% analyse
for cell=1:max(labelCell(:))
    tmpCell=labelCell==cell;
    tmpFociBin=bwCh2.*tmpCell;
    tmpFociRaw=imCh2.*tmpCell;
    areaColoc(cell)=nnz(tmpFociBin); % total area of foci
    intenColoc(cell)=sum(tmpFociRaw(:)); % total intensity of foci
    
    cc = bwconncomp(tmpFociBin,8);
    numFoci(cell)  = cc.NumObjects; % number of foci
end

if strcmp(vars.plot, 'Yes')
    plotTmp = labelCell+labelDAPI;
    plotTmp(bwCh2==1) = round(1.2*max(max(plotTmp)));
    figure; imagesc(plotTmp), title(['Segmented Cells & Foci - ' filename])
end
    
end