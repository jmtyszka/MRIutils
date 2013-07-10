function [k,info,errmsg] = pvmloadfid(serdir)
% [k,info,errmsg] = pvmloadfid(serdir)
%
% Load a PvM method fid file into a matrix and return the exam information.
%
% ARGS:
% serdir = series directory containing the fid file
%
% RETURNS:
% k    = complex double k-space data
% info = info structure generated from Parx files
% errmsg = conditional error message
%
% If an error occurs during data reading, k is returned empty
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 09/10/2002 JMT Adapt from parxloadfid.m (JMT)
%          11/03/2004 JMT Add 2D multiecho, multislice support
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2002-2006 California Institute of Technology.
% All rights reserved.

% Initialize return args
k = [];

% Load info from this series directory
[info, status, errmsg] = pvmloadinfo(serdir);

if status < 0
  return
end

% Assume fid file is in serdir
fidname = fullfile(serdir,'fid');

% Open the file
switch info.byteorder
  case 'littleEndian'
    fd = fopen(fidname,'r','ieee-le');
  case 'bigEndian'
    fd = fopen(fidname,'r','ieee-be');
end

if (fd < 1)
  errmsg = sprintf('Could not open %s to read\n', fidname);
  return
end

% Read the data
switch info.acqdepth
case 32
  d = fread(fd, Inf, 'int32');
case 16
  d = fread(fd, Inf, 'int16');
otherwise
  errmsg = sprintf('Unknown bit depth (%s)\n', info.acqdepth);
  return;
end

% Close the file
fclose(fd);

% Simplify coding
nx = info.sampdim(1);
ny = info.sampdim(2);
nz = info.sampdim(3);
ni = info.sampdim(4)/2;

% Handle digital filter acquisition
if nx < 128
  nx_dig = 128;
else
  nx_dig = nx;
end

% Round up to nearest whole power of 2
nx_dig = 2^(ceil(log(nx_dig)/log(2)));

% Total samples of k-space
nsamps = nx_dig * ny * nz * ni * 2;

% Check that FID data matches expected dimensions
nfid = length(d);
if nsamps > nfid
  fprintf('Data in fid file is smaller than expected (%d < %d)\n', nfid, nsamps);
  return
else
  if nsamps < nfid
    fprintf('Data in fid file is larger than expected (%d > %d)\n', nfid, nsamps);
    return
  end
end

% Recompose into a complex vector
d = complex(d(1:2:nsamps),d(2:2:nsamps));

% Reshape the dataset
if info.etl > 1
  k = reshape(d, nx_dig, info.etl, ny/info.etl, nz);
  k = permute(k, [1 3 2 4]);
  k = reshape(k, nx_dig, ny, nz);
else
  switch info.ndim
    case 2
      % 2D data organized as (X,TE,Z,Y) where Z is the slice dimension
      k = squeeze(reshape(d, nx_dig, ni, nz, ny));
      % Reorder dimensions to (X,Y,Z,TE)
      k = permute(k,[1 4 3 2]);
      % Handle multiecho multislice 2D
    case 3
      k = squeeze(reshape(d, nx_dig, ny, nz, ni));
  end
end

% Discard the digitizer zero padding if present (nx < 128)
k = k(1:nx,:,:,:);

% Remove singlet dimensions
k = squeeze(k);