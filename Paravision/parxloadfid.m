function [k,info,errmsg] = parxloadfid(scandir)
% [k,info,errmsg] = parxloadfid(scandir)
%
% Load a Paravision fid file into a matrix.
% Also return the exam information.
%
% ARGS:
% scandir = scan directory containing the fid file
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
% DATES  : 09/25/2000 JMT Adapt from BIC_Load2DSeq.m
%          11/13/2000 JMT Use parxloadinfo call to gather data info
%          05/23/2001 JMT Add general path separator
%          01/05/2003 JMT Add endian handling and incomplete fid padding
%          01/25/2004 JMT Add switch for PvM method data
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2000-2006 California Institute of Technology.
% All rights reserved.

% Flag for Paravision versions < 4x
older_parx = 0;

% Check for PvM method data
if isequal(parxacqmeth(scandir),'pvm')
  [k,info,errmsg] = pvmloadfid(scandir);
  return
end

% Initialize return args
k = [];

% Load info from this series directory
[info, status, errmsg] = parxloadinfo(scandir);

if status < 0
  return
end

% Assume fid file is in scan director
fidname = fullfile(scandir,'fid');

% Open the file
switch info.byteorder
  case 'littleEndian'
    fd = fopen(fidname,'r','ieee-le');
  case 'bigEndian'
    fd = fopen(fidname,'r','ieee-be');
end

% Read the data
switch info.acqdepth
case 32
  d = double(fread(fd, Inf, 'int32'));
case 16
  d = fread(fd, Inf, 'int16');
otherwise
  errmsg = sprintf('Unknown bit depth (%s)\n', info.depth);
  return;
end

% Close the file
fclose(fd);

% Simplify coding
nx = info.sampdim(1);
ny = info.sampdim(2);
nz = info.sampdim(3);
ni = info.sampdim(4);

% Handle digital filter acquisition for Pv versions < 4x
% Pv pads filter samples < 128 to 128 points in fid
if older_parx

  if nx < 128
    nx_dig = 128;
  else
    nx_dig = nx;
  end

  % Round up to nearest whole power of 2
  nx_dig = 2^(ceil(log(nx_dig)/log(2)));
  
else
  
  nx_dig = nx;
  
end

% Total samples of k-space
nsamps = nx_dig * ny * nz * ni * 2;

% Check that FID data matches expected dimensions
nfid = length(d);
if nsamps > nfid
  fprintf('Data in fid file is smaller than expected (%d < %d)\n', nfid, nsamps);
  
  % Determine acquired NI (cf prescribed NI)
  ni_orig = ni;
  ni = fix(nfid / (nx_dig * ny * nz * 2));
  nsamps = nx_dig * ny * nz * ni * 2;

  fprintf('Cropping number of images from %d to %d\n', ni_orig, ni);
  
  % Crop d to maximum length without corruption
  d = d(1:nsamps);
  
else
  if nsamps < nfid
    fprintf('Data in fid file is larger than expected (%d > %d)\n', nfid, nsamps);
    fprintf('Exiting\n');
    return
  end
end

% Handle echo train length
etl = info.etl;
if info.navigate
  if isequal(info.method,'BIC_UFLARE3D');
    etl = etl + 2;
  else
    etl = etl + 1;
  end
end

% Recompose into a complex vector
d = complex(d(1:2:nsamps),d(2:2:nsamps));

% Reshape the dataset
if etl > 1
  k = reshape(d, nx_dig, etl, ny/etl, nz);
  k = permute(k, [1 3 2 4]);
  k = reshape(k, nx_dig, ny, nz);
else
  % Permute dimensions to place 2D echo dimension 3rd (X,Y,TE)
  % 2D data is originally organized as (X,TE,Y)
  if info.nechoes > 1 && info.ndim == 2
    k = squeeze(reshape(d, nx_dig, nz, ny, ni));
    k = permute(k,[1 3 2]);
  else
    k = squeeze(reshape(d, nx_dig, ny, nz, ni));
  end

end

% Discard the digitizer zero padding if present (nx < 128)
k = k(1:nx,:,:,:);

% Remove singlet dimensions
k = squeeze(k);