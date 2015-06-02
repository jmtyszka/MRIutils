function H = fermi3(dims, fr, fw, echopos)
% H = fermi3(dims, fr, fw, echopos)
%
% Return the 3D Fermi filter function
%
% ARGS:
% dims  = filter dimensions
% fr    = fractional filter radius in each dimension
% fw    = fractional filter transition width in each dimension
% echopos = fractional echo position in readout window (1st dimension)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech Biological Imaging Center
% DATES  : 02/04/2003 JMT Adapt from hamming3.m (JMT)

% Default arguments
if nargin < 2; fr = 0.50; end
if nargin < 3; fw = 0.05; end
if nargin < 4; echopos = 0.5; end

% Reproduce scalar args as 1 x 3 vectors
if length(fr) == 1; fr = fr * [1 1 1]; end
if length(fw) == 1; fw = fw * [1 1 1]; end

% Adjust the filter radius for the echo position
fr(1) = 2 * (0.5 + abs(echopos - 0.5)) * fr(1);

% Construct a normalized spatial matrix
FOV = [1 1 1];
Offset = [-echopos -0.5 -0.5]; 
[xc,yc,zc] = voxelgrid(dims, FOV, Offset);

% Construct 3D Fermi filter matrix
Hx = 1 ./ (1 + exp((abs(xc) - fr(1))/fw(1)));
Hy = 1 ./ (1 + exp((abs(yc) - fr(2))/fw(2)));
Hz = 1 ./ (1 + exp((abs(zc) - fr(3))/fw(3)));
H = Hx .* Hy .* Hz;