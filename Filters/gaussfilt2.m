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
