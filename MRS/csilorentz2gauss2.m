function kb = csilorentz2gauss2(k,sw,T2,FWHM_gauss)
% Lorentz-Gauss conversion of CSI spectral dimension
%
% kb = csilorentz2gauss2(k,sw,T2,FWHM_gauss)
%
% Lorentz to Gaussian filter applied to spectral dimension
% of a 2D spatial, 1D spectral CSI dataset.
% Assume spectral dimension is first dimension
%
% ARGS :
% k    = complex CSI k-space (nf x nx x ny)
% sw   = spectral width in Hz
% T2   = estimated T2 relaxation time in seconds
% FWHM_gauss = required FWHM Gaussian linebroadening in Hz
%
% RETURNS:
% kb = line-broadened complex CSI k-space
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 01/29/2004 JMT Adapt from linebroaden.m (JMT)
%          01/17/2006 JMT M-Lint corrections
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


if nargin < 3
  kb = [];
  return
end

% CSI dimensions
[nf,nx,ny] = size(k);

% Create the time domain (kf) vector
dt = 1/sw;
t = ((1:nf)-1)' * dt;

% Generate the Exponential and Gaussian time-domain filters
FWHM_exp = 1 / (pi * T2);
[S0,Hexp] = exp_tfilter(t, zeros(1,nf), -FWHM_exp);
[S0,Hgauss] = gauss_tfilter(t, zeros(1,nf), FWHM_gauss);
Ht = Hexp .* Hgauss;

% Replicate in spatial dimensions
Ht = repmat(reshape(Ht,[nf 1 1]),[1 nx ny]);

% Apply filter
kb = Ht .* k;
