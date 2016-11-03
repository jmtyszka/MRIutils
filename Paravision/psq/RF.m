function IC = RF(IC,alpha,phi)
% IC = RF(IC,alpha,phi)
%
% Apply an RF pulse with a given flip, alpha, and phase, phi
%
% ARGS :
% IC    = isochromate structure
% alpha = flip angle in degrees
% phi   = RF phase angle in degrees
%
% RETURNS :
% IC    = updated isochromat structure
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 03/29/2002 From scratch
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

% Precessional phase angle varies with position
alpha = alpha * pi / 180;
phi = phi * pi/180;

% Trig functions
ca = cos(alpha);
sa = sin(alpha);
cp = cos(phi);
sp = sin(phi);

% Rotation matrices
Rz = [cp -sp 0; sp cp 0; 0 0 1];
Rx = [1 0 0; 0 cp -sp; 0 sp cp];

% Apply rotation to all isochromats - M is a 3 x N matrix
IC.M = Rx * Rz * IC.M;
