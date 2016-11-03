function xrgb = colorize3d(x, lims, cmap)
% Colorize a 3D scalar image using intensity limits and a colormap
%
% xrgb = colorize3d(x, lims, cmap)
%
% ARGS :
% x    = 3D scalar image
% lims = intensity limits for colorization (2 x 1)
% cmap = colormap to use in colorization (n x 3)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 12/14/2004 JMT Adapt from csi_colorize.m (JMT)
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

% Default return
xrgb = [];

if isempty(lims)
  lims = [min(x(:)) max(x(:))];
end

% Get colormap limits
maxl = max(lims);
minl = min(lims);

if maxl == minl
  maxl = minl + 1;
end

% Clamp x to the limits
x(x > maxl) = maxl;
x(x < minl) = minl;

% Scale x to the integer range 1..nc
nc = length(cmap);
if nc == 0; return; end
x = fix((x - minl) / (maxl - minl) * (nc - 1)) + 1;

% Colorize and reshape
[nx,ny,nz] = size(x);
xrgb = reshape(cmap(x, :), nx, ny, nz, 3);

% Place color dimension 3rd (x y c z)
xrgb = permute(xrgb,[1 2 4 3]);

