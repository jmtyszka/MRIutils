function kb = csilinebroaden2(k,sw,lb)
% Line broaden the spectral dimension of a 2D spatial CSI
%
% kb = csilinebroaden2(k,sw,lb)
%
% Assume spectral dimension is first dimension
%
% ARGS :
% k  = complex CSI k-space (nf x nx x ny)
% sw = spectral width in Hz
% lb = Gaussian linebroadening FWHM in Hz
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

% Generate the time-domain Gaussian filter
sd_w = 2 * pi * lb / sqrt(8 * log(2));
sd_t = 1/sd_w;
Ht = exp(-0.5 * (t / sd_t).^2);

% Replicate in spatial dimensions
Ht = repmat(reshape(Ht,[nf 1 1]),[1 nx ny]);

% Apply filter
kb = Ht .* k;
