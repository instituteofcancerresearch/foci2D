function [labelDAPI, labelCell] = nucSegBorders(nucIm, vars)
%% Adam Tyson | 2018-05-08 | adam.tyson@icr.ac.uk
% Takes a 2D image of nuclei, segments, estimates cytoplasmic borders
% returns labelled images

% segment
imFilt = imgaussfilt(nucIm,vars.filtSigmaCh1);
minSig = min(imFilt(:));
maxSig = max(imFilt(:));
imNorm = (imFilt - minSig) / (maxSig - minSig);

levelOtsu = vars.threshScaleCh1*graythresh(imNorm);
bwNuc = imbinarize(imNorm,levelOtsu);
bwNuc=~(bwareaopen(~bwNuc, vars.holeFill)); % fill holes
bwNuc=bwareaopen(bwNuc,vars.noiseRem); % remove small objs
labelDAPI = bwlabel(bwNuc);

% get cell boundaries
dist = bwdist(bwNuc); % take distance transform & watershed
ws = watershed(dist);
cellEdges = ws == 0; % where ws=0 - boundary between cells
labelCell = bwlabel(~cellEdges); % lavel what remains
end