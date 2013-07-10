function H = gauss2(dims, FWHM, echopos)
% Return the 2D radial Gaussian filter function with a given PSF FWHM 
%
% SYNTAX: H = gauss2(dims, FWHM, echopos)
%
% ARGS:
% dims    = filter dimensions
% FWHM    = PSF FWHM in voxels [1.0]
% echopos = fractional echo position in first dimension (0 .. 1) [0.5]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech Biological Imaging Center
% DATES  : 06/24/2003 JMT Adapt from hamming2.m (JMT)
%          03/16/2009 JMT Switch to PSF FWHM specification

if nargin < 2;  FWHM = 1.0; end
if nargin < 3; echopos = [0.5 0.5]; end

switch length(echopos)
  case 1
    echopos = [echopos 0.5];
  case 2
    echopos = [echopos(:)'];
  otherwise
end

% Calculate the fractional radius of the k-space Gaussian filter function
% corresponding to the PSF FWHM provided.
% Assumes normalized k-space coordinates run from -0.5 to 0.5
Rf = 2 * pi * FWHM / sqrt(8 * log(2));

% Construct a spatial radius matrix
% Note that if x-space has voxel dimension, then k-space has a FOV of 1 in
% each dimension
FOV = [1 1];
Offset = -echopos; 
[xc,yc] = voxelgrid2(dims, FOV, Offset);
k = sqrt(xc.*xc + yc.*yc);

% Construct 2D Gaussian filter
H = exp(-0.5 * (k * Rf).^2);