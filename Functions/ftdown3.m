function sdwn = ftdown3(s, dims, absflag, hammingflag)
% Downsample a 3D dataset using the Fourier inverse space
%
% sdwn = ftdown3(s, dims, absflag, hammingflag)
%
% ARGS:
% s          = 3D dataset
% dx, dy, dz = dimensions of downsampled dataset 
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

% Default args
if nargin < 3; absflag = 0; end
if nargin < 4; hammingflag = 0; end

% FFT all dimensions - place origin at center of dataset
sf = fftshift(fftn(s));

% Establish central section of k-space
[nx,ny,nz] = size(s);

dx = dims(1);
dy = dims(2);
dz = dims(3);

x0 = fix((nx-dx)/2)+1;
x1 = fix((nx+dx)/2);
y0 = fix((ny-dy)/2)+1;
y1 = fix((ny+dy)/2);
z0 = fix((nz-dz)/2)+1;
z1 = fix((nz+dz)/2);

% Extract central section of k-space
sfcrop = sf(x0:x1,y0:y1,z0:z1);

% Hamming filter k-space if requested
if hammingflag
  sfcrop = sfcrop .* hamming3(size(sfcrop));
end

% Inverse FFT all dimensions and take magnitude
sdwn = ifftn(fftshift(sfcrop));

% Calculate absolute image if requested
if absflag
  sdwn = abs(sdwn);
end
