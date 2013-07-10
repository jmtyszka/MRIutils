function [x,y,z] = shcart(r,CofM,de_v,az_v,sepcalc)
% [x,y,z] = shcart(r,CofM,de_v,az_v,sepcalc)
%
% Return the cartesian coordinates of points on the spherical harmonic surface
% defined by the coefficients in r[].
% If sepcalc is 'sep', x,y,z are coordinate meshes, otherwise x,y,z have same
% dimensions as de_v and az_v
%
% ARGS :
% r         = complex Ylm coefficients [Y(0,0) Y(1,-1) Y(1,0) Y(1,1) Y(2,-2) ...]
% CofM      = center of mass vector [x0 y0 z0] default = [0 0 0]
% de_v,az_v = declination and azimuth vectors
% sepcalc   = 'sep' or 'full' for separable or full harmonic calculations (see sh.m)
%
% RETURNS :
% x,y,z = cartesian surface mesh for spherical harmonic sum
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 01/17/2002 Adapt from shsum.m (JMT)
%          01/23/2002 Change to angle vectors defining sub-segment of surface

% Default arguments
if nargin < 2
  CofM = [0 0 0];
end
if nargin < 4
  de_v = (0:5:180) * pi / 180;
  az_v = (0:5:360) * pi / 180;
end
if nargin < 5
  sepcalc = 'sep';
end

% Generate uniformly sampled spherical harmonic surface
% Take real part, eliminating small imaginary residuals
[R,de,az] = shsum(r,de_v,az_v,sepcalc);

% Calculate the elevation for use by Matlab functions
el = pi/2 - de;

% Convert to cartesian coordinates
[x,y,z] = sph2cart(az,el,real(R));

% Take real part of coordinates
x = real(x) + CofM(1);
y = -real(y) + CofM(2);
z = real(z) + CofM(3);