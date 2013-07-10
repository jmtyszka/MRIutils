function [scrop,xlims,ylims] = autocrop(s,tol)
% Conservative automatic cropping of a 2D image
%
% [scrop,xlims,ylims] = autocrop(s,tol)
%
% ARGS :
% s     = 2D image data
% tol   = crop tolerance - fractional expansion of crop limits [0.1]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 01/09/2002 JMT From scratch
%          10/21/2003 JMT Add tolerance argument
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2011 California Institute of Technology.
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

if nargin < 2; tol = 0.1; end

if ndims(s) ~= 2
  fprintf('Image has %d dimensions. Only 2D images supported\n', ndims(s));
  return
end

[nx,ny] = size(s);

proj_x = sum(s,2);
proj_y = sum(s,1);

mask_x = find(proj_x > max(proj_x) * tol);
mask_y = find(proj_y > max(proj_y) * tol);

xlo = min(mask_x);
xhi = max(mask_x);
ylo = min(mask_y);
yhi = max(mask_y);

% Expand limits by 10% of the new range

dx = round((xhi - xlo + 1) * tol);
dy = round((yhi - ylo + 1) * tol);

xlo = xlo - dx;
if xlo < 1; xlo = 1; end

xhi = xhi + dx;
if xhi > nx; xhi = nx; end

ylo = ylo - dy;
if ylo < 1; ylo = 1; end

yhi = yhi + dy;
if yhi > ny; yhi = ny; end

xlims = xlo:xhi;
ylims = ylo:yhi;

% Apply crop limits
scrop = s(xlims,ylims);
