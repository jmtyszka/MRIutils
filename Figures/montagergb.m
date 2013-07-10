function mrgb = montagergb(rgb3d,mdim)
% Create an RGB montage of a 3D image
%
% mrgb = montagergb(rgb3d,mdim)
%
% Create an RGB montage from the (x,y,rgb,z) data
% with n columns. This function is very similar to
% the Matlab montage command except that the
% montage is returned rather than displayed as a figure.
%
% NB In Matlab, x -> rows, y ->columns
%
% ARGS:
% rgb3d = Color 3D image (x,y,rgb,z)
% mdim  = montage image dimensions (nrows ncols)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte CA
% DATES  : 03/09/2001 JMT From scratch
%          02/18/2005 JMT Add nrows, ncols args
%          03/01/2005 JMT Replace nrows, ncols with mdim
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

% Default return
mrgb = [];

[nx,ny,nc,nz] = size(rgb3d);

% Check for RGB data (nc = 3)
if nc ~= 3
  fprintf('*** Matrix size (%d x %d x %d x %d does not match expected format (nx * ny * 3 * nz)\n', nx, ny, nc, nz);
  return
end

nrows = mdim(1);
ncols = mdim(2);

% Create 2D RGB montage space
mrgb = zeros(nx * nrows, ny * ncols, 3);

% Create vector of z values to sample
z = round(linspace(1,nz,nrows*ncols));

% Slice counter
zc = 1;

for r = 1:nrows
  for c = 1:ncols
    
    % Pane coordinates
    xs = (1:nx) + (r-1) * nx;
    ys = (1:ny) + (c-1) * ny;
    
    % Add new pane to montage
    mrgb(xs, ys, :) = squeeze(rgb3d(:,:,:,z(zc)));
    
    % Increment slice counter
    zc = zc + 1;
    
  end
end
