function H = lorentz2(dims, Rf)
% H = lorentz2(dims, Rf)
%
% Return the 2D radial Gaussian filter function with sd = Rf voxels
%
% ARGS:
% dims    = filter dimensions
% Rf      = fractional FWHM of Lorentzian
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech Biological Imaging Center
% DATES  : 06/24/2003 JMT Adapt from hamming2.m (JMT)

if nargin < 2  Rf = 1.0; end

% Construct a spatial radius matrix
% Note that if x-space has voxel dimension, then k-space has a FOV of 1 in
% each dimension
% Construct a spatial radius matrix
FOV = [1 1];
Offset = [-0.5 -0.5]; 
[xc,yc] = voxelgrid2(dims, FOV, Offset);
r2 = xc.*xc + yc.*yc;

% Construct 1D Gaussian filter vector
a2 = Rf^2 / 2;
H = a2 ./ (a2 + r2);