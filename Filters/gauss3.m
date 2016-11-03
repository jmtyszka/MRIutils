function H = gauss3(dims, FWHM, echopos)
% Return the 3D radial Gaussian filter function with a given PSF FWHM 
%
% SYNTAX: H = gauss3(dims, FWHM, echopos)
%
% ARGS:
% dims    = filter dimensions
% FWHM    = PSF FWHM in voxels [1.0]
% echopos = fractional echo position in first dimension (0 .. 1) [0.5]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech Biological Imaging Center
% DATES  : 06/24/2003 JMT Adapt from hamming2.m (JMT)
%          03/12/2009 JMT Switch to PSF FWHM specification
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

if nargin < 2;  FWHM = 1.0; end
if nargin < 3; echopos = [0.5 0.5 0.5]; end

switch length(echopos)
  case 1
    echopos = [echopos 0.5 0.5];
  case 2
    echopos = [echopos(:)' 0.5];
  otherwise
end

% Calculate the fractional radius of the k-space Gaussian filter function
% corresponding to the PSF FWHM provided.
% Assumes normalized k-space coordinates run from -0.5 to 0.5
Rf = 2 * pi * FWHM / sqrt(8 * log(2));

% Construct a spatial radius matrix
% Note that if x-space has voxel dimension, then k-space has a FOV of 1 in
% each dimension
FOV = [1 1 1];
Offset = -echopos; 
[xc,yc,zc] = voxelgrid(dims, FOV, Offset);
k = sqrt(xc.*xc + yc.*yc + zc.*zc);

% Construct 3D Gaussian filter
H = exp(-0.5 * (k * Rf).^2);
