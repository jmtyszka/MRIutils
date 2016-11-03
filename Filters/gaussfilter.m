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
%
% The MIT License (MIT)
%
% Copyright (c) 2016 Mike Tyszka
%
%   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
%   documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
%   rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
%   permit persons to whom the Software is furnished to do so, subject to the following conditions:
%
%   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
%   Software.
%
%   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
%   WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
%   COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
%   OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
