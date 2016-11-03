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
