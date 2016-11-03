function [scrop,xlims,ylims,zlims] = autocrop3(s,tol)
% Conservative automatic cropping of a 3D image
%
% [scrop,xlims,ylims,zlims] = autocrop(s,tol)
%
% ARGS :
% s      = 3D image data
% tol    = crop tolerance - fractional expansion of crop limits [0.1]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 03/01/2002 JMT Adapt from autocrop.m
%          10/21/2003 JMT Replace threshold with Otsu's threshold and
%                         switch to binary image projections. Add crop tolerance argument.
%          12/09/2005 JMT Switch to sampled Otsu threshold
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

% Default args
if nargin < 2; tol = 0.1; end

% Grab data dimensions
[nx,ny,nz] = size(s);

% Normalize signal intensity
sf = max(s(:));
s = s / sf;

% Estimate Otsu threshold from subsample
nsamp = 1000;
inds = fix(rand(1,nsamp) * nx * ny * nz + 1);
samp = s(inds);
th = graythresh(samp);

% Create a mask
m = s > th;

% Project mask onto each axis
proj_x = sum(sum(m,2),3);
proj_y = sum(sum(m,1),3);
proj_z = sum(sum(m,1),2);

% Determine values above 0.25 in each projection
thresh = 0.25;
mask_x = find(proj_x > max(proj_x) * thresh);
mask_y = find(proj_y > max(proj_y) * thresh);
mask_z = find(proj_z > max(proj_z) * thresh);

% Find limits of masked projections
xlo = min(mask_x);
xhi = max(mask_x);
ylo = min(mask_y);
yhi = max(mask_y);
zlo = min(mask_z);
zhi = max(mask_z);

% Fractional expansion of limits by tol
dx = round(nx * tol);
dy = round(ny * tol);
dz = round(nz * tol);

% Constrain crop limits to within dataset
xlo = xlo - dx;
if xlo < 1; xlo = 1; end

xhi = xhi + dx;
if xhi > nx; xhi = nx; end

ylo = ylo - dy;
if ylo < 1; ylo = 1; end

yhi = yhi + dy;
if yhi > ny; yhi = ny; end

zlo = zlo - dz;
if zlo < 1; zlo = 1; end

zhi = zhi + dz;
if zhi > nz; zhi = nz; end

% Return crop ranges
xlims = xlo:xhi;
ylims = ylo:yhi;
zlims = zlo:zhi;

% Apply crop limits and restore scaling
scrop = s(xlims,ylims,zlims) * sf;
