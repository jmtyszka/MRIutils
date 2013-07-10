function kh = csihamming2d(k)
% kh = csihamming2d(dims, Rf)
%
% Apply a radial 2D Hamming to the spatial dimensions of
% a CSI. Assumes first dimension is spectral.
%
% ARGS:
% k = complex CSI data (nf x nx x ny)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech Biological Imaging Center
% DATES  : 01/29/2004 JMT 

if nargin < 1
  kh = [];
  return;
end

% Copy k-space
kh = k;

% Construct a spatial radius matrix
[nf,nx,ny] = size(k);
FOV        = [1 1];
Offset     = -FOV/2; 
[xc,yc] = voxelgrid2([nx ny], [1 1], [-0.5 -0.5]);

r = sqrt(xc.*xc + yc.*yc);

% Clamp radius to <= 1
r(r > 1) = 1;

% Construct 3D Hamming filter matrix
H = 0.54 + 0.46 * cos(pi * r);

% Replicate in f dimension
H = repmat(reshape(H,[1 nx ny]),[nf 1 1]);

% Apply filter
kh = k .* H;