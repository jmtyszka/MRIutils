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
% Copyright 2002-2006 California Institute of Technology.
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