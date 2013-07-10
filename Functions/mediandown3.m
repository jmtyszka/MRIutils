function b = mediandown3(a, f)
% Median downsample a 3D matrix by a factor of 2^f
%
% b = mediandown3(a, f)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 07/19/2001 JMT From scratch
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2001-2006 California Institute of Technology.
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

% Source dimensions
[nx, ny, nz] = size(a);

% Destination dimensions
k = 2^f;
nxf = fix(nx / k);
nyf = fix(ny / k);
nzf = fix(nz / k);

% Make space for new downsampled image
b = zeros(nxf, nyf, nzf);

ki = (1:k) - 1;

hwb = waitbar(0);

for z = 1:k:nz

  waitbar(z/nz,hwb);
  
  zk = ceil(z/k);

  for y = 1:k:ny
  
    yk = ceil(y/k);
    
    for x = 1:k:nx
    
      xk = ceil(x/k);

      this_k = a(x + ki, y + ki, z + ki);
      
      b(xk,yk,zk) = median(this_k(:));

    end
  end
end

close(hwb);