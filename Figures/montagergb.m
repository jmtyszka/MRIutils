function mrgb = montagergb(rgb3d,mdim)
% Create an RGB montage of a 3D image
%
% mrgb = montagergb(rgb3d,mdim)
%
% Create an RGB montage from the (x,y,rgb,z) data
% with n columns. This function is very similar to
% the Matlab montage command except that the
% montage is returned rather than displayed as a figure.
%
% NB In Matlab, x -> rows, y ->columns
%
% ARGS:
% rgb3d = Color 3D image (x,y,rgb,z)
% mdim  = montage image dimensions (nrows ncols)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte CA
% DATES  : 03/09/2001 JMT From scratch
%          02/18/2005 JMT Add nrows, ncols args
%          03/01/2005 JMT Replace nrows, ncols with mdim
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
mrgb = [];

[nx,ny,nc,nz] = size(rgb3d);

% Check for RGB data (nc = 3)
if nc ~= 3
  fprintf('*** Matrix size (%d x %d x %d x %d does not match expected format (nx * ny * 3 * nz)\n', nx, ny, nc, nz);
  return
end

nrows = mdim(1);
ncols = mdim(2);

% Create 2D RGB montage space
mrgb = zeros(nx * nrows, ny * ncols, 3);

% Create vector of z values to sample
z = round(linspace(1,nz,nrows*ncols));

% Slice counter
zc = 1;

for r = 1:nrows
  for c = 1:ncols
    
    % Pane coordinates
    xs = (1:nx) + (r-1) * nx;
    ys = (1:ny) + (c-1) * ny;
    
    % Add new pane to montage
    mrgb(xs, ys, :) = squeeze(rgb3d(:,:,:,z(zc)));
    
    % Increment slice counter
    zc = zc + 1;
    
  end
end
