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

% Interpolated voxel dimensions
dx = fov ./ dim;

% Voxel coordinate vectors for each dimension
x = ((1:dim(1))-0.5) * dx(1) + offset(1);
y = ((1:dim(2))-0.5) * dx(2) + offset(2);
z = ((1:dim(3))-0.5) * dx(3) + offset(3);

% Create voxel center coords for interpolated matrix
[xc, yc, zc] = ndgrid(x, y, z);
