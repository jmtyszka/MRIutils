function sdwn = ftdown4d(s, dx, dy, dz, dt)
% Downsample a 4D dataset by calculating 4D local means
%
% sdwn = ftdown4d(s, dx, dy, dz, dt)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 06/23/2000 JMT From scratch
%          01/17/2006 JMT M-Lint corrections
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

% FFT all dimensions - place origin at center of dataset
sf = fftshift(fftn(s));

% Establish central section of k-space
[nx,ny,nz,nt] = size(s);
x0 = fix((nx-dx)/2)+1;
x1 = fix((nx+dx)/2);
y0 = fix((ny-dy)/2)+1;
y1 = fix((ny+dy)/2);
z0 = fix((nz-dz)/2)+1;
z1 = fix((nz+dz)/2);
t0 = fix((nt-dt)/2)+1;
t1 = fix((nt+dt)/2);

% Extract central section of k-space
sfcrop = sf(x0:x1,y0:y1,z0:z1,t0:t1);

% Inverse FFT all dimensions
sdwn = abs(ifftn(fftshift(sfcrop)));
