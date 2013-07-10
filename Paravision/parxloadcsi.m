function [k, info] = parxloadcsi(serdir)
% [k, info] = parxloadcsi(serdir)
%
% Load a Paravision CSI file into a matrix.
% Also return the exam information.
%
% ARGS:
% serdir = series directory containing the fid file
%
% RETURNS:
% info = info structure generated from Parx files
% k    = complex double k-space data
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 09/25/2000 Adapt from BIC_Load2DSeq.m
%          11/13/2000 Use parxloadinfo call to gather data info
%          04/18/2001 Adapt for Paravision 2x 32 bit CSI data
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2001-2006 California Institute of Technology.
% All rights reserved.

fname = 'parxloadcsi';

% Initialize return argument
k = [];

% Load info from this series directory
info = parxloadinfo(serdir);

if strcmp(info.name,'Unkown')
  fprintf('%s: Could not load study information\n', fname);
  return
end

% Assume fid file is in serdir
fidname = [serdir '\fid'];

% Open the file
fd = fopen(fidname,'r','ieee-be');
if (fd < 1)
  fprintf('%s: Could not open %s to read\n', fname, fidname);
  return
end

% Read the data
info.dim(1) = info.dim(1)/2; % Not sure why nf is half requested value yet
nsamps = 2 * prod(info.dim);
switch info.depth
case 32
  d = fread(fd, Inf, 'int32');
case 16
  d = fread(fd, Inf, 'int16');
otherwise
  fprintf('%s: Unknown bit depth (%s)\n', fname, info.depth);
  d = zeros(1,nsamps);
end

% Close the file
fclose(fd);

% Check for incomplete dataset
if (length(d) ~= nsamps)
  fprintf('%s: only %d of %d samples read\n', fname, length(d), nsamps)
  return
end

% Simplify coding
nf = info.dim(1);
nx = info.dim(2);
ny = info.dim(3);
nz = info.dim(4);

% Recompose into a complex vector
d = complex(d(1:2:nsamps), d(2:2:nsamps));

% Reshape into a 4D dataset
k = reshape(d, nf, nx, ny, nz);

% Discard the DSP prefill points
k = k((info.prefill+1):nf,:,:,:);