function [k0,b] = pvmkspacebline(k)
% Remove low frequency baseline artifact from k-space
% These artifacts generally appeara as a single intensity "star"
% artifact in real space, which may be off-center.
%
% SYNTAX: [k0,b] = pvmkspacebline(k)
%
% ARGS:
% k = 3D complex k-space
%
% RETURNS:
% k0 = corrected complex k-space
% b  = complex baseline
%
% AUTHOR: Mike Tyszka, Ph.D.
% PLACE: Caltech
% DATES: 10/28/2010 From scratch
%
% Copyright 2010 California Institute of Technology
% All rights reserved.

if nargin < 1; help pvmkspacebline; return; end

verbose = 1;
mask_radius = 0.125;

[nx,ny,nz] = size(k);

% Assume first dimension (kx) is readout and correct all kx lines
% with a masked, downsampled polynomial fit.

% Normalized coordinates [-0.5, 0.5];
x = ((1:nx)-fix(nx/2)-1)/nx;
y = ((1:ny)-fix(ny/2)-1)/ny;
z = ((1:nz)-fix(nz/2)-1)/nz;
[xm,ym,zm] = ndgrid(x,y,z);

% Radial coordinate in k-space
r = sqrt(xm.*xm + ym.*ym + zm.*zm);

% Radial mask of central k-space
mask = r > mask_radius;

% Allocate space for arrays
k0 = zeros(size(k));
b = zeros(size(k));

fprintf('Starting baseline correction\n');
fprintf('Central mask radius: %0.3f\n', mask_radius);

for zc = 1:nz
  
  fprintf('Processing plane %d/%d\n', zc, nz);
  
  % Extract complex z-plane from k-space
  k_xy = k(:,:,zc);
  mask_xy = mask(:,:,zc);
  xm_xy = xm(:,:,zc);
  ym_xy = ym(:,:,zc);
  
  % Estimate a baseline for real and imag channels
  br_xy = estbline(xm_xy, ym_xy, real(k_xy), mask_xy, verbose);
  bi_xy = estbline(xm_xy, ym_xy, imag(k_xy), mask_xy, verbose);
  
  % Create complex baseline
  b_xy = br_xy + 1i * bi_xy;
  
  % Save the baseline estimate for this z-plane
  b(:,:,zc) = b_xy;
  
  % Subtract complex baseline for this z-plane
  k0(:,:,zc) = k_xy - b_xy;
  
  figure(1); clf; colormap(hot);
  subplot(231), imagesc(real(k_xy));
  subplot(232), imagesc(real(b_xy));
  subplot(233), imagesc(real(k_xy-b_xy));
  subplot(234), imagesc(imag(k_xy));
  subplot(235), imagesc(imag(b_xy));
  subplot(236), imagesc(imag(k_xy-b_xy));
  drawnow;
  
end

fprintf('Done\n');

%-------------------------------------------------
% Estimate 2D baseline
%-------------------------------------------------

function b = estbline(xm,ym,kxy,maskxy,verbose)

% Extract subset of points in mask
x = xm(maskxy);
y = ym(maskxy);
k = kxy(maskxy);

% Original and sampled vector lengths
n = length(x);
nsamp = fix(n * 0.2);
if verbose; fprintf('Sampling %0.2f%% of points\n',nsamp/n*100); end

% Extract random sample of points from list
inds = randi(n,[nsamp 1]);
x = x(inds);
y = y(inds);
k = k(inds);

% Surface fit
if verbose; fprintf('Calculating 2D fit\n'); end
f = fit([x,y],k,'poly55');

% Calculate baseline over all points
if verbose; fprintf('Creating full baseline\n'); end
b = f(xm,ym);

if verbose > 1
  figure(1); clf
  plot(f,[x,y],k);
  drawnow
end