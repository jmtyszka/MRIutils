function [s, info, errmsg] = pvmload2dseq(scandir)
% [s, info, errmsg] = pvmload2dseq(scandir)
%
% Load a PvM 2dseq file into Matlab
% Assumes method, acqp, subject files are present for this series.
%
% ARGS :
% scandir = Paravision study directory containing imnd file
% 
% RETURNS :
% s       = data as 3D double matrix
% info    = information structure for the data
% errmsg  = error message - empty if all ok
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 09/25/2000 JMT Adapt from BIC_Load2DSeq.m
%          04/11/2001 JMT Use parxloadinfo to determine parameters
%          08/07/2001 JMT Added more comments
%          12/06/2001 JMT Add error message support
%          04/04/2003 JMT Add support for PvM
%          08/23/2004 JMT Complete recotx support and vsize reordering
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2000-2006 California Institute of Technology.
% All rights reserved.

errmsg = [];

% Default args
if nargin < 1
  scandir = pwd;
end

% Default parameters
s = [];
info.name = 'Nobody';

% Load the PvM scan information
[info,status] = pvmloadinfo(scandir);  

% Check that info files were read
if status < 0
  errmsg = 'Could not load information files';
  return
end

% Return if this is spectroscopy data
if strcmp(info.method,'VSEL_SE') || strcmp(info.method,'VSEL_STE')
  errmsg = 'Cannot display spectroscopy data';
  return
end

% Construct 2dseq pathname
filename = fullfile(scandir,'pdata','1','2dseq');

% Open the file
switch info.byteorder
  case 'littleEndian'
    fd = fopen(filename,'r','ieee-le');
  case 'bigEndian'
    fd = fopen(filename,'r','ieee-be');
end

if (fd < 1)
  errmsg = sprintf('Could not open %s to read', filename);
  return;
end

% Read the data
switch info.recodepth
case 32
  d = fread(fd, Inf, 'int32');
case 16
  d = fread(fd, Inf, 'int16');
otherwise
  errmsg = 'Unknown bit depth';
  return
end  

% Close the file
fclose(fd);

if (prod(info.recodim) ~= length(d))
  errmsg = sprintf('2dseq file is incomplete (%d expected, %d loaded)', prod(info.recodim), length(d));
  return
end

% Rescale values for quantitation
% Use the map parameters in the RECO header
% Assume all slices have same map scaling (JMT 4/22/2002)
cal_min = info.map_slope(1); % Calibrated minimum
cal_max = info.map_max(1);   % Calibrated maximum
vox_min = info.minima(1);    % Voxel minimum
vox_max = info.maxima(1);    % Voxel maximum

% Calibrate the grayscale transform slope
map_slope = (cal_max - cal_min) / (vox_max - vox_min);

% Apply linear calibration function
d = (d - vox_min) * map_slope + cal_min;

% Apply transposition
switch info.recotx(1)
  case 1
    % Swap XY
    info.recodim = info.recodim([2 1 3 4]);
    info.vsize   = info.vsize([2 1 3 4]);
  case 2
    % Swap XZ
    info.recodim = info.recodim([3 2 1 4]);
    info.vsize   = info.vsize([3 2 1 4]);
  case 3
    % Swap YZ
    info.recodim = info.recodim([1 3 2 4]);
    info.vsize   = info.vsize([1 3 2 4]);
  otherwise
    % Do nothing
end

% Reshape the data
s = reshape(d, info.recodim');