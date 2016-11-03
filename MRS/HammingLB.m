function HammingLB(n, BW)
% Simulate spectral linebroadening for time-domain Hamming filtering
%
% HammingLB(n,BW)
%
% ARGS:
% n  = Number of points
% BW = spectral bandwidth in Hz
%
% RETURNS:
% None
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 11/23/1999 JMT From scratch
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

dt = 1/BW;
T = (n-1) * dt;
t = 0:dt:T;
H = 0.54 + 0.46 * cos(pi * t/T);

df = BW/n;
f = -BW/2:df:BW/2-df;
Hf = fftshift(fft(H));
Hfr = real(Hf);

subplot(2,1,1), plot(H);
subplot(2,1,2), plot(f, Hfr);

% Calculate true FWHM of frequency response
maxHfr = max(Hfr);
inds = find(Hfr > maxHfr/2);

minf = min(f(inds));
maxf = max(f(inds));

FWHM = maxf - minf;
fprintf('FWHM of filter response is %gHz\n', FWHM);

