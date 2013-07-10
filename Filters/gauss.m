function H = gauss(n, Rf, echopos)
% H = gauss(n, Rf, echopos)
%
% Return the 1D Gaussian filter function with sd = Rf voxels
%
% ARGS:
% n       = filter length
% Rf      = filter radius in voxels [0.5]
% echopos = fractional echo position (0 .. 1) [0.5]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech Biological Imaging Center
% DATES  : 06/24/2003 JMT Adapt from hamming2.m (JMT)

validate = 0;

if nargin < 2  Rf = 1.0; end
if nargin < 3 echopos = 0.5; end

% Construct a spatial radius matrix
% Note that if x-space has voxel dimension, then k-space has a FOV of 1 in
% each dimension
k = (1:n)/n - echopos;

% Construct 1D Gaussian filter vector
H = exp(-0.5 * (k * Rf * 2 * pi).^2);

if validate

  PSF = fftshift(abs(fft(fftshift(H))));
  PSF = PSF / max(PSF(:));
  x = (1:n) - n/2 - 1;
  
  subplot(121), plot(k,H); title('H');
  subplot(122), plot(x,PSF); title('PSF');
  set(gca,'Ylim',[exp(-0.5) 1.1]);
  
end