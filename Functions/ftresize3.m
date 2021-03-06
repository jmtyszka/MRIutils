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
