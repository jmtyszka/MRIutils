function [sb,Ht] = linebroaden(s,f,FWHM,type)
% Gaussian line broaden a complex spectrum.
%
% [sb,Ht] = linebroaden(s,f,FWHM,type)
%
% ARGS :
% s    = complex spectrum vector
% f    = chemical shift vector (ppm)
% FWHM = FWHM of frequency domain Gaussian linebroadening in ppm
% type = signal type 'fid' or 'echo' ['fid']
%
% RETURNS:
% sb = line broadened spectrum
% Ht = time domain filter
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 07/19/2002 JMT From scratch
%          10/28/2003 JMT Add type argument
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

if nargin < 4; type = 'fid'; end

% Flatten spectrum
s = s(:);

% Create the time domain vector
n  = length(s);
BW = max(f(:)) - min(f(:));
dt = 1/BW;

switch type
  case 'fid'
    t = ((1:n)-1)' * dt;
  case 'echo'
    t = fftshift(((1:n)-1-fix(n/2))' * dt);
end

% Generate the time-domain Gaussian filter
sd_w = 2 * pi * FWHM / sqrt(8 * log(2));
sd_t = 1/sd_w;
Ht = exp(-0.5 * (t / sd_t).^2);

% Recreate FID from spectrum
fid = ifft(fftshift(s));

% Apply linebroadening filter in time domain
fidH = fid .* Ht;

% Reconstruct linebroadened spectrum
sb = fftshift(fft(fidH));
