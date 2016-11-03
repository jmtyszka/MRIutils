function H = lorentz2(dims, Rf)
% H = lorentz2(dims, Rf)
%
% Return the 2D radial Gaussian filter function with sd = Rf voxels
%
% ARGS:
% dims    = filter dimensions
% Rf      = fractional FWHM of Lorentzian
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech Biological Imaging Center
% DATES  : 06/24/2003 JMT Adapt from hamming2.m (JMT)
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

if nargin < 2  Rf = 1.0; end

% Construct a spatial radius matrix
% Note that if x-space has voxel dimension, then k-space has a FOV of 1 in
% each dimension
% Construct a spatial radius matrix
FOV = [1 1];
Offset = [-0.5 -0.5]; 
[xc,yc] = voxelgrid2(dims, FOV, Offset);
r2 = xc.*xc + yc.*yc;

% Construct 1D Gaussian filter vector
a2 = Rf^2 / 2;
H = a2 ./ (a2 + r2);
