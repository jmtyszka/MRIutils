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
% The MIT License (MIT)
%
% Copyright (c) 2016 Mike Tyszka
%
%   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
%   documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
%   rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
%   permit persons to whom the Software is furnished to do so, subject to the following conditions:
%
%   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
%   Software.
%
%   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
%   WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
%   COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
%   OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
