function m = montagegray(S, opts)
% Create a 2D montag of a scalar 3D matrix
%
% m = bic_montage(S, opts)
%
% opts = montage options structure
% .rows  = number of montage rows
% .cols  = number of montage cols
% .start = first slice to display
% .skip  = slice skip
% .downsize = downsize factor in all dimensions
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 06/12/2000 JMT Start from scratch
%          03/12/2002 JMT Add default args and structure filler
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

% Grab data dimensions
[nx, ny, nz] = size(S);

if nargin < 1

  fprintf('Image data is required\n');
  return;
  
end

if nargin < 2; opts = []; end

% Fill missing arguments
if ~isfield(opts,'cols'); opts.cols = ceil(sqrt(nz)); end
if ~isfield(opts,'rows'); opts.rows = ceil(nz / opts.cols); end
if ~isfield(opts,'start'); opts.start = 1; end
if ~isfield(opts,'skip'); opts.skip = 1; end

% Estimate a sensible downsize factor for an 1280 x 1024 screen
if ~isfield(opts,'downsize')
  nxtot = opts.cols * nx;
  nytot = opts.rows * ny;
  xscale = nxtot / 1280;
  yscale = nytot / 1024;
  opts.downsize = ceil(max([xscale yscale]));
end

% Generate the montage
z = opts.start;
ds = opts.downsize;

mxi = 1:ds:nx;
myi = 1:ds:ny;
mnx = length(mxi);
mny = length(myi);

m = zeros(opts.rows * mnx, opts.cols * mny);

for mr = 1:opts.rows
  for mc = 1:opts.cols
    
    if (z >= 1) && (z <= nz)
      mont_x = (1:mnx) + (mr-1)*mnx;
      mont_y = (1:mny) + (mc-1)*mny;
      m(mont_x,mont_y) = squeeze(S(mxi,myi,z));
    end

    z = z + opts.skip;
    
  end
end
