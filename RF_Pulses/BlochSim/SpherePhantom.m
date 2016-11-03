function [xi,yi,zi,Mxi,Myi,Mzi] = SpherePhantom(Dims,FOV,Rs)
% [xi,yi,zi,Mxi,Myi,Mzi] = SpherePhantom(Dims,FOV,Rs)
%
% Generate isochromats for a 3D spherical phantom
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 02/20/2002 From scratch
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

% Half field of view
hFOV = FOV/2;

% Generate coordinate vectors
x = linspace(-hFOV(1),hFOV(1),Dims(1));
y = linspace(-hFOV(2),hFOV(2),Dims(2));
z = linspace(-hFOV(3),hFOV(3),Dims(3));

% Generate coordinate mesh
[xi,yi,zi] = ndgrid(x,y,z);

% Calculate radial coordinate
[th,phi,r] = cart2sph(xi,yi,zi);

% Fill isochromat magnetization with [0 0 1] within sphere boundary
Mxi = zeros(size(xi));
Myi = Mxi;
Mzi = double(r <= Rs);
