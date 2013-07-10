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
% Copyright 1999-2006 California Institute of Technology.
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
%

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

