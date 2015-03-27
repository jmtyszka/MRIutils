function H = gauss3psf(dims, sigma)
% Return the 3D radial Gaussian PSF with a given sigma
%
% SYNTAX: H = gauss3psf(dims, sigma)
%
% ARGS:
% dims  = PSF dimensions
% sigma = Gaussian sigma in voxels
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech Biological Imaging Center
% DATES  : 2015-02-17 JMT Adapt from gauss3.m

% Construct a spatial radius matrix
center = fix(dims/2.0);
xv = (1:dims(1)) - center(1);
yv = (1:dims(2)) - center(2);
zv = (1:dims(3)) - center(3);
[mx,my,mz] = ndgrid(xv, yv, zv);
r = sqrt(mx.*mx + my.*my + mz.*mz);

% Construct radial 3D Gaussian PSF
H = exp(-0.5 * (r/sigma).^2);