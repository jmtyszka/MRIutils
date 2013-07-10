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