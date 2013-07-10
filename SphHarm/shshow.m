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