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
% Copyright 2002-2006 California Institute of Technology.
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
