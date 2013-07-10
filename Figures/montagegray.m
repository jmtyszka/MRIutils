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
% Copyright 2011 California Institute of Technology.
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
