function H = hanning3(dims, radii)
% H = hanning3(dims, radii)
%
% Return the radial 3D Hanning filter function
%
% ARGS:
% dims  = filter dimensions
% radii = filter radius in each dimension in voxel units
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech Biological Imaging Center
% DATES  : 07/26/2001 Adapt from shim_hamming

% Construct a spatial radius matrix
FOV = dims ./ radii;
[xc,yc,zc] = voxelgrid(dims, FOV, -FOV/2);
r = sqrt(xc.*xc + yc.*yc + zc.*zc);

% Clamp radius to <= 1
r(r > 1) = 1;

% Construct 3D Hanning filter matrix
H = 0.5 * (1 + cos(pi * r));