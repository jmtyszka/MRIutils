function [xs, ys] = voxelgrid2(dims, fov, offset)
% Create coordinate mesh for voxel centers in a 2D image
%
% [xs, ys] = voxelgrid2(dims, fov, offset)
%
% Create a plaid coordinate grid for a given 2D sampled image dims and FOV
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 08/07/2001 JMT Adapt from voxelgrid
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

vsize = fov ./ dims;

x = (0.5:(dims(1)-0.5)) * vsize(1) + offset(1);
y = (0.5:(dims(2)-0.5)) * vsize(2) + offset(2);

[xs, ys] = ndgrid(x, y);