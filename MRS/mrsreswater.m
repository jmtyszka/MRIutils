function [s_est,w_est] = mrsreswater(s)
% Estimate residual water signal by smoothing in the time domain.
%
% [s_est,w_est] = mrsreswater(s)
%
% Returns both the non-water estimate and water estimate for a given
% frequency domain spectrum.
%
% ARGS:
% s = complex frequency domain 1H spectrum
%
% RETURNS:
% s_est = estimate of non-water spectrum
% w_est = estimate of water spectrum
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 11/17/2004 JMT From memory
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

method = 'smooth';

n = length(s);

k = ifft(fftshift(s));

% Normalize maximum value
sf = max(abs(k(:)));
k = k / sf;

% Estimate the "noise" - will contain non-water resonances
sd = noisesd(k);
fprintf('Non-water signal sd estimated at %0.3g or %0.3f%%\n',sd,sd/max(k(:))*100);

% Split out components
kr = real(k);
ki = imag(k);

t = 1:length(k);

switch method
  case 'csaps'
    krs = fnval(csaps(t,kr),t);
    kis = fnval(csaps(t,ki),t);
  case 'spaps'
    [sp,krs] = spaps(t,kr,sqrt(sd));
    [sp,kis] = spaps(t,ki,sqrt(sd));
  case 'smooth'
    krs = smooth(t,kr,n/200);
    kis = smooth(t,ki,n/200);
end

% Reconstruct complex time domain
ks = complex(krs,kis);
ks = ks(:);

% Restore scaling
ks = ks * sf;

% Forward FFT
w_est = fftshift(fft(ks));

% Calculate residual water spectrum
s_est = s - w_est;

figure(1);clf
plot(t,kr,t,krs);
legend('Re[k]','Smooth Re[k]');






