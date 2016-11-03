function H = fermi2(dims, fr, fw, echopos)
% H = fermi2(dims, fr, fw, echopos)
%
% Return the 2D Fermi filter function
%
% ARGS:
% dims  = filter dimensions
% fr    = fractional filter radius in each dimension
% fw    = fractional filter transition width in each dimension
% echopos = fractional echo position in readout window (1st dimension)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech Biological Imaging Center
% DATES  : 02/04/2003 JMT Adapt from hamming3.m (JMT)
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

% Default arguments
if nargin < 2, fr = 0.45; end
if nargin < 3, fw = 0.05; end
if nargin < 4, echopos = 0.5; end

if length(fr) == 1, fr = [fr fr]; end
if length(fw) == 1, fw = [fw fw]; end

% Adjust the filter radius for the echo position
fr(1) = 2 * (0.5 + abs(echopos - 0.5)) * fr(1);

% Construct a normalized spatial matrix
FOV = [1 1];
Offset = [-echopos -0.5];
[xc,yc] = voxelgrid2(dims, FOV, Offset);

% Construct 2D Fermi filter matrix
Hx = 1 ./ (1 + exp((abs(xc) - fr(1))/fw(1)));
Hy = 1 ./ (1 + exp((abs(yc) - fr(2))/fw(2)));
H = Hx .* Hy;
