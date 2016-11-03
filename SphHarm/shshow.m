function [x,y,z] = shcart(r)
% [x,y,z] = shcart(r)
%
% Return the cartesian coordinates of points on the spherical harmonic surface
% defined by the coefficients in r[]. x,y and z are 2D coordinate meshs suitable
% for display using mesh or surf.
%
% ARGS :
% r  = Ylm coefficients [Y(0,0) Y(1,-1) Y(1,0) Y(1,1) Y(2,-2) ...]
%
% RETURNS :
% x,y,z = 
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 01/17/2002 Adapt from shsum.m (JMT)
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

% Create a uniform sampling mesh for the fitted surface
de_v = 0:(pi/30):pi;
az_v = 0:(pi/30):(2*pi);
[de,az] = meshgrid(de_v,az_v);

% Calculate the elevation for use by Matlab functions
el = pi/2 - de;

% Generate uniformly sampled spherical harmonic surface
R = real(shsum(r,de,az));

% Convert to cartesian coordinates
[x,y,z] = sph2cart(az,el,R);

% Take real part of coordinates
x = real(x);
y = real(y);
z = real(z);
