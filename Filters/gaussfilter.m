function b = gaussfilter(a,FWHM)
% Apply a 1D Gaussian spatial filter in the Fourier domain
%
% SYNTAX: b = gaussfilter(a,FWHM)
%
% ARGS:
% a = original 1D data
% w = FWHM of PSF in samples [1.0]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech Biological Imaging Center
% DATES  : 11/28/2006 JMT From scratch
%          03/12/2009 JMT Tidy up commenting

if nargin < 2;  FWHM = 1.0; end

% Remember original dimensions of a
adim = size(a);

% Force a to column vector
a = a(:);

% Calculate the fractional radius of the k-space Gaussian filter function
% corresponding to the PSF FWHM provided
Rf = 2 * pi * FWHM / sqrt(8 * log(2));

% Forward 1D FFT
k = fftshift(fft(fftshift(a)));

%% Construct 1D Gaussian filter
nx = length(k);
kx = ((((1:nx)-1)-fix(nx/2))/nx)';

% Construct k-space filter function
H = exp(-0.5 * kx .* kx * Rf * Rf);

% Inverse FFT
b = real(fftshift(ifft(fftshift(k.*H))));

% Restore original dimensions
b = reshape(b,adim);