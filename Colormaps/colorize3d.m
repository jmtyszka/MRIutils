function xrgb = colorize3d(x, lims, cmap)
% Colorize a 3D scalar image using intensity limits and a colormap
%
% xrgb = colorize3d(x, lims, cmap)
%
% ARGS :
% x    = 3D scalar image
% lims = intensity limits for colorization (2 x 1)
% cmap = colormap to use in colorization (n x 3)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 12/14/2004 JMT Adapt from csi_colorize.m (JMT)
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2004-2006 California Institute of Technology.
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
xrgb = [];

if isempty(lims)
  lims = [min(x(:)) max(x(:))];
end

% Get colormap limits
maxl = max(lims);
minl = min(lims);

if maxl == minl
  maxl = minl + 1;
end

% Clamp x to the limits
x(x > maxl) = maxl;
x(x < minl) = minl;

% Scale x to the integer range 1..nc
nc = length(cmap);
if nc == 0; return; end
x = fix((x - minl) / (maxl - minl) * (nc - 1)) + 1;

% Colorize and reshape
[nx,ny,nz] = size(x);
xrgb = reshape(cmap(x, :), nx, ny, nz, 3);

% Place color dimension 3rd (x y c z)
xrgb = permute(xrgb,[1 2 4 3]);

