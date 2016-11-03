function [s0,H] = pvmdestar(s)
% Remove star artifact from MR images
% This artifact is typically caused by signal un-encoded by the 
% field gradients and may be off-center in the image
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 11/01/2010 JMT From scratch
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

% Find center of the artifact
sflat = s(:);
[smax,imax] = max(sflat);

[x0,y0,z0] = ind2sub(size(s),imax);
m = [x0 y0 z0];
sz = size(s);
c = fix(sz/2);

fprintf('Maximum found at (%d,%d,%d)\n', x0, y0, z0);

% Create a 3D radial Gaussian filter to match the artifact
H = 1 - gauss3(sz,8,0.5);

H = circshift(H,m-c);

s0 = s .* H;
