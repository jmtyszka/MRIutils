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
