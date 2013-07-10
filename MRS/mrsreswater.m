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
% Copyright 2004-2006 California Institute of Technology.
% All rights reserved.
%
% This file is part of MRutils.
%
% MRutils is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% MRutils is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with MRutils; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

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






