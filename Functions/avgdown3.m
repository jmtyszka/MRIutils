function sdwn = avgdown3(s, dx, dy, dz)
% Downsample a 3D dataset using [dx,dy,dz] local means.
%
% sdwn = avgdown3(s, dx, dy, dz)
%
% ARGS:
% s = original 3D scalar data
% dx,dy,dz = size of kernel for mean downsampling
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 06/23/2000 JMT From scratch
%          01/17/2006 M-Lint corrections
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

[nx,ny,nz] = size(s);

% Calculate size of downsampled volume
nxd = nx/dx;
nyd = ny/dy;
nzd = nz/dz;

if nxd ~= fix(nxd) || nyd ~= fix(nyd) || nzd ~= fix(nzd)
  fprintf('avgdown3 requires that dx,dy,dz are factors of nx,ny,nz\n');
  sdwn = [];
  return;
end

% Allocate memory for the downsampled data
sdwn = zeros(nxd, nyd, nzd);

% Loop over all locations in the downsampled volume
for z = 1:nzd

  zs = (0:(dz-1)) + dz * (z-1) + 1;

  for y = 1:nyd

    ys = (0:(dy-1)) + dy * (y-1) + 1;

    for x = 1:nxd
      
      xs = (0:(dx-1)) + dx * (x-1) + 1;
      
      % Extract values to be averaged
      samp = s(xs,ys,zs);
      
      % Record local average
      sdwn(x,y,z) = mean(samp(:));
      
    end
    
  end
  
end
