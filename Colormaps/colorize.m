function srgb = colorize(s, lims, cmap)
% Colorize a matrix using intensity limits and a colormap
%
% srgb = colorize(s, lims, cmap)
%
% ARGS :
% s    = 3D scalar field
% lims = optional intensity limits for colorization (2 x 1)
% cmap = optional colormap to use in colorization (n x 3)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte CA and Caltech BIC
% DATES  : 02/21/2001 JMT From scratch
%          04/17/2004 JMT Update for general MR use
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

if nargin < 2; lims = []; end
if nargin < 3; cmap = jet(128); end

% Create a default RGB return image
[nx,ny,nz] = size(s);
nc = 3;
srgb = zeros(nx,ny,nz,nc);

% Autoscale if lims is empty
if isempty(lims)
  lims = [min(s(:)) max(s(:))];
end

% Get colormap limits
maxl = max(lims);
minl = min(lims);

if maxl == minl
  maxl = minl + 1;
end

% Clamp s to the limits
s(s > maxl) = maxl;
s(s < minl) = minl;

% Scale s to the integer range 1..nc
nc = length(cmap);
if nc == 0; return; end
s = fix((s - minl) / (maxl - minl) * (nc - 1)) + 1;

% Colorize and reshape
srgb = reshape(cmap(s, :), nx, ny, nz, 3);

% Move the color dimension to 3rd place for
% compatibility with other Matlab RGB routines
srgb = permute(srgb,[1 2 4 3]);

