function H = hamming2(dims, Rf, echopos)
% H = hamming2(dims, Rf, echopos)
%
% Return the radial 2D Hanning filter function
%
% ARGS:
% dims    = filter dimensions
% Rf      = fractional filter radius in each dimension [0.5 0.5]
% echopos = fractional echo position in first dimension (0 .. 1) [0.5]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech Biological Imaging Center
% DATES  : 07/26/2001 Adapt from shim_hamming
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

if nargin < 2  Rf = [0.5 0.5]; end
if nargin < 3 echopos = 0.5; end

% Construct a spatial radius matrix
FOV = [1 1] ./ Rf;
Offset = [-echopos -0.5] ./ Rf; 
[xc,yc] = voxelgrid2(dims, FOV, Offset);
r = sqrt(xc.*xc + yc.*yc);

% Clamp radius to <= 1
r(r > 1) = 1;

% Construct 3D Hamming filter matrix
H = 0.5 + 0.5 * cos(pi * r);
