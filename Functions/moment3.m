function m = moment3(s, morder)
% Calculate the m-order spatial moments of a 3D matrix
%
% m = moment3(s, morder)
%
% AUTHOR : Mike Tyszka, Ph.D
% PLACE  : Caltech BIC
% DATES  : 11/07/2000 JMT From scratch
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

% Grab size of data
[nx,ny,nz] = size(s);

% Useful constants
hx = (nx-1)/2;
hy = (ny-1)/2;
hz = (nz-1)/2;

% Create coordinate grids
[x, y, z] = ndgrid(-hx:hx, -hy:hy, -hz:hz);

% Calculate spatial products
px = s .* (x.^morder);
py = s .* (y.^morder);
pz = s .* (z.^morder);

% Calculate moments as integrals over the volume
m = [sum(px(:)) sum(py(:)) sum(pz(:))];
