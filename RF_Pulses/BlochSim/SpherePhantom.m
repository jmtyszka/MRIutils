function [xi,yi,zi,Mxi,Myi,Mzi] = SpherePhantom(Dims,FOV,Rs)
% [xi,yi,zi,Mxi,Myi,Mzi] = SpherePhantom(Dims,FOV,Rs)
%
% Generate isochromats for a 3D spherical phantom
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 02/20/2002 From scratch

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
