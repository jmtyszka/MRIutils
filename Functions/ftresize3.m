function snew = ftresize3(s, dims, absflag, hammingflag)
% Resize a 3D dataset using the Fourier inverse space
%
% snew = ftresize3(s, dims, absflag, hammingflag)
%
% ARGS:
% s       = 3D dataset
% dims    = new dimensions of dataset following FT resizing
% absflag = 0 = complex data returned, 1 = absolute data returned
% hammingflag = 0 = no Hamming filter applied prior to IFT, 1 = Hamming filtered
%
% RETURNS:
% snew    = FT resized 3D dataset
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 06/23/2000 JMT From scratch
%          09/08/2001 JMT Generalize to resizing from downsampling alone
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
ksrc = fftshift(fftn(s));

% Establish central section of k-space
[nx,ny,nz] = size(ksrc);

dx = dims(1);
dy = dims(2);
dz = dims(3);

xoff = fix(abs(nx - dx)/2);
yoff = fix(abs(ny - dy)/2);
zoff = fix(abs(nz - dz)/2);

if dx < nx
  xsrc = (1:dx) + xoff;
  xdst = 1:dx;
else
  xsrc = 1:nx;
  xdst = (1:nx) + xoff;
end

if dy < ny
  ysrc = (1:dy) + yoff;
  ydst = 1:dy;
else
  ysrc = 1:ny;
  ydst = (1:ny) + yoff;
end

if dz < nz
  zsrc = (1:dz) + zoff;
  zdst = 1:dz;
else
  zsrc = 1:nz;
  zdst = (1:nz) + zoff;
end

% Hamming filter k-space if requested
if hammingflag
  ksrc = ksrc .* hamming3(size(ksrc));
end

% Construct source k-space (always <= to original k-space)
kdst = zeros(dims);
kdst(xdst,ydst,zdst) = ksrc(xsrc,ysrc,zsrc);

% Inverse FFT all dimensions and take magnitude
snew = ifftn(fftshift(kdst));

% Calculate absolute image if requested
if absflag
  snew = abs(snew);
end
