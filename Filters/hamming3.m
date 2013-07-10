function H = hamming3(dims, Rf, echopos)
% H = hamming3(dims, Rf, echopos)
%
% Return the radial 3D Hamming filter function
%
% ARGS:
% dims  = filter dimensions
% Rf    = fractional filter radius in each dimension
% echopos = fractional echo position within readout window (1st dimension)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech Biological Imaging Center
% DATES  : 07/26/2001 JMT Adapt from shim_hamming
%          04/15/2004 JMT Add echopos argument

if nargin < 2 Rf = [0.5 0.5 0.5]; end
if nargin < 3 echopos = 0.5; end

% Construct a spatial radius matrix
FOV = [1 1 1] ./ Rf;
Offset = [-echopos -0.5 -0.5] ./ Rf; 
[xc,yc,zc] = voxelgrid(dims, FOV, Offset);
r = sqrt(xc.*xc + yc.*yc + zc.*zc);

% Clamp radius to <= 1
r(r > 1) = 1;

% Construct 3D Hamming filter matrix
H = 0.54 + 0.46 * cos(pi * r);