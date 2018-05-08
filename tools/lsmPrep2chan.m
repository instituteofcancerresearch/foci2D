function [data, voxSize, omeMeta]=lsmPrep2chan(fileIn)
% load and parse .lsm files (Zeiss) using bioformats
% 2 channel only
%% Adam Tyson 2018-05-03 adam.tyson@icr.ac.uk
% Adapted from cziPrep.m
datacell=bfopen(fileIn); % load  data

%% Grab metadata - all from https://www.openmicroscopy.org/site/support/bio-formats5.1/developers/matlab-dev.html#ome-metadata
omeMeta = datacell{1, 4};
voxelSizeX = omeMeta.getPixelsPhysicalSizeX(0).value(ome.units.UNITS.MICROM); % in µm
voxelSizeXdouble = voxelSizeX.doubleValue();                                  % The numeric value represented by this object after conversion to type double
voxelSizeY = omeMeta.getPixelsPhysicalSizeY(0).value(ome.units.UNITS.MICROM); % in µm
voxelSizeYdouble = voxelSizeY.doubleValue();                                  % The numeric value represented by this object after conversion to type double
voxelSizeZ = omeMeta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM); % in µm
voxelSizeZdouble = voxelSizeZ.doubleValue(); 

voxSize=[voxelSizeXdouble voxelSizeYdouble voxelSizeZdouble]; % combine together to pass one array out of function
%% separate channels (if dual channel image)
for z=1:length(datacell{1,1})/2 % for the number of z images
data.channel1(:,:,z)=double(datacell{1,1}{2*z-1,1}); % get channel 1 
data.channel2(:,:,z)=double(datacell{1,1}{2*z,1}); % get channel 2 
end
end