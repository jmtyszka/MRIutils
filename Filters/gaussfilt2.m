function b = gaussfilt2(a,FWHM)
% b = gaussfilt2(a,fwhm)
%
% Apply a Gaussian spatial filter in the Fourier domain
%
% ARGS:
% a = original 2D image
% w = FWHM of gaussian blur in pixels
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech Biological Imaging Center
% DATES  : 11/28/2006 JMT From scratch

verbose = 0;

if nargin < 2;  w = 1; end

Rf = 2 * pi * FWHM / sqrt(8 * log(2));

k = fftshift(fft2(fftshift(a)));

%% Construct 2D Gaussian filter
[nx,ny] = size(k);
kxv = (((1:nx)-1)-fix(nx/2))/nx;
kyv = (((1:ny)-1)-fix(ny/2))/ny;
[kxm,kym] = ndgrid(kxv,kyv);

k2 = kxm.*kxm + kym.*kym;

H = exp(-0.5 * k2 * Rf * Rf);

b = real(fftshift(ifft2(fftshift(k.*H))));

if verbose
  figure(1); clf
  subplot(221), imagesc(a);
  subplot(222), imagesc(log(abs(k)));
  subplot(223), imagesc(H);
  subplot(224), imagesc(b);
end