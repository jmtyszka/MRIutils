function [xc, yc, zc] = voxelgrid(dim, fov, offset)
% Create coordinate mesh for voxel centers in a 3D image
%
% [xc,yc,zc] = voxelgrid(dim, fov, offset)
%
% Create matrices of the x, y and z co-ordinates of
% the voxel centers for a given FOV, matrix size and offset
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 11/01/2000 JMT From scratch
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2000-2006 California Institute of Technology.
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

% Interpolated voxel dimensions
dx = fov ./ dim;

% Voxel coordinate vectors for each dimension
x = ((1:dim(1))-0.5) * dx(1) + offset(1);
y = ((1:dim(2))-0.5) * dx(2) + offset(2);
z = ((1:dim(3))-0.5) * dx(3) + offset(3);

% Create voxel center coords for interpolated matrix
[xc, yc, zc] = ndgrid(x, y, z);
