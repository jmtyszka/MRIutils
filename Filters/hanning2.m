function H = hamming2(dims, Rf, echopos)
% H = hamming2(dims, Rf, echopos)
%
% Return the radial 2D Hanning filter function
%
% ARGS:
% dims    = filter dimensions
% Rf      = fractional filter radius in each dimension [0.5 0.5]
% echopos = fractional echo position in first dimension (0 .. 1) [0.5]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech Biological Imaging Center
% DATES  : 07/26/2001 Adapt from shim_hamming

if nargin < 2  Rf = [0.5 0.5]; end
if nargin < 3 echopos = 0.5; end

% Construct a spatial radius matrix
FOV = [1 1] ./ Rf;
Offset = [-echopos -0.5] ./ Rf; 
[xc,yc] = voxelgrid2(dims, FOV, Offset);
r = sqrt(xc.*xc + yc.*yc);

% Clamp radius to <= 1
r(r > 1) = 1;

% Construct 3D Hamming filter matrix
H = 0.5 + 0.5 * cos(pi * r);