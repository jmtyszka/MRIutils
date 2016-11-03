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
