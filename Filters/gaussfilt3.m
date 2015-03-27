function b = gaussfilt3(a,FWHM)
% b = gaussfilt3(a,FWHM)
%
% Apply a Gaussian spatial filter in the Fourier domain
%
% ARGS:
% a = original 3D image
% FWHM = FWHM of gaussian filter in pixels
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech Biological Imaging Center
% DATES  : 11/28/2006 JMT From scratch
%          2015-02-04 JMT Adapt from gaussfilt2.m
%
% Copyright 2015 California Institute of Technology
% All rights reserved.

if nargin < 2; FWHM = 1.0; end

% Forward FFT to k-space
k = fftshift(fftn(fftshift(a)));

% Generate k-space filter
H = gauss3(size(a), FWHM);

% Filter and inverse FFT
b = real(fftshift(ifftn(fftshift(k.*H))));