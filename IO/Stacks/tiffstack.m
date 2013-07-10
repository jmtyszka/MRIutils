function tiffstack(fname, s)
% Write a 3D matlab matrix as a single-file TIFF stack.
%
% tiffstack(fname, s)
%
% Assumes s pre-scaled to value range 0..1 in all channels.
%
% ARGS:
% fname    = filename for TIFF stack
% s        = scalar 3D dataset
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte CA
% DATES  : 04/24/2001 JMT Adapt from pngstack.m
%          04/27/2004 JMT Add scaling argument
%          03/21/2005 JMT Switch to single-file stack output
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2001-2006 California Institute of Technology.
% All rights reserved.
%
% This file is part of MRutils.
%
% MRutils is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% MRutils is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with MRutils; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

if nargin < 2
  help tiffstack
end

% Grab size of 3D matrix
sdims = ndims(s);
switch sdims
  case {2,3}
    nz = size(s,3);
  case 4
    nz = size(s,4);
  otherwise
    fprintf('Dataset dimensionality is wierd (%d)\n', sdims);
    return
end

% Check scaling
smin = min(s(:));
smax = max(s(:));

if smin < 0
  fprintf('Minimum value < 0: consider rescaling\n');
end
if smax > 1
  fprintf('Maximum value > 1: consider rescaling\n');
end

%------------------------------------------------
% Write out stack
%------------------------------------------------

% Uncompressed for maximum portability
compression = 'none';

for z = 1:nz

  % Write first slice to file in overwrite mode
  % All subsequent slices appended to file
  if z == 1
    wmode = 'overwrite';
  else
    wmode = 'append';
  end
  
  % Extract slice from 3D 1 or 3 channel data
  switch sdims
  case 3
    sz = squeeze(s(:,:,z));
  case 4
    sz = squeeze(s(:,:,:,z));
  end

  % Write one z-slice to the file
  try
    imwrite(sz,fname,'tif','Compression',compression,'WriteMode',wmode);
  catch
    fprintf('Problem writing slice to %s\n', fname);
  end

end