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
% Copyright 2000-2006 California Institute of Technology.
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