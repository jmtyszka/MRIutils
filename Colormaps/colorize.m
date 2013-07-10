function srgb = colorize(s, lims, cmap)
% Colorize a matrix using intensity limits and a colormap
%
% srgb = colorize(s, lims, cmap)
%
% ARGS :
% s    = 3D scalar field
% lims = optional intensity limits for colorization (2 x 1)
% cmap = optional colormap to use in colorization (n x 3)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte CA and Caltech BIC
% DATES  : 02/21/2001 JMT From scratch
%          04/17/2004 JMT Update for general MR use
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

if nargin < 2; lims = []; end
if nargin < 3; cmap = jet(128); end

% Create a default RGB return image
[nx,ny,nz] = size(s);
nc = 3;
srgb = zeros(nx,ny,nz,nc);

% Autoscale if lims is empty
if isempty(lims)
  lims = [min(s(:)) max(s(:))];
end

% Get colormap limits
maxl = max(lims);
minl = min(lims);

if maxl == minl
  maxl = minl + 1;
end

% Clamp s to the limits
s(s > maxl) = maxl;
s(s < minl) = minl;

% Scale s to the integer range 1..nc
nc = length(cmap);
if nc == 0; return; end
s = fix((s - minl) / (maxl - minl) * (nc - 1)) + 1;

% Colorize and reshape
srgb = reshape(cmap(s, :), nx, ny, nz, 3);

% Move the color dimension to 3rd place for
% compatibility with other Matlab RGB routines
srgb = permute(srgb,[1 2 4 3]);

