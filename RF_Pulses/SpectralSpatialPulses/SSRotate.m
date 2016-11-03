function newm = SSRotate(m, alpha, axis)
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

% Transfrom axis to spherical coordinates
[th,phi,r] = cart2sph(axis(1), axis(2), axis(3));

% Rotate world so that axis lies along x axis
cth = cos(th); sth = sin(th);
cphi = cos(phi); sphi = sin(phi);

% Theta is the counter-clockwise angle about z from the x axis
IRtheta = [cth sth 0; -sth cth 0; 0 0 1];

% Phi is the elevation angle about y now that we've undone theta
IRphi = [cphi 0 sphi; 0 1 0; -sphi 0 cphi];

% Rotate world so that axis lies along positive x
IR = IRphi * IRtheta;
m = IR * m;

% Now rotate by alpha about the x axis
ca = cos(alpha); sa = sin(alpha);
Ra = [1 0 0; 0 ca -sa; 0 sa ca];

m = Ra * m;

% Reverse spherical rotations
newm = inv(IR) * m;
