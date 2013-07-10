function [StH, Ht] = gauss_tfilter(t,St,FWHM)
% Gaussian time-domain filtering
%
% [StH, Ht] = gauss_tfilter(t,St,FWHM)
%
% Generate the time domain Gaussian filter which
% has a given FWHM in the frequency domain.
%
% ARGS :
% t    = time vector (seconds)
% St   = time domain signal
% FWHM = FWHM of frequency domain Gaussian (Hz)
%
% RETURNS:
% StH  = filtered time domain signal
% Ht   = time domain filter function
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 02/26/2004 JMT Adapt from linebroaden.m (JMT)
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

% Generate the time-domain Gaussian filter
sd_w = 2 * pi * FWHM / sqrt(8 * log(2));
sd_t = 1/sd_w;
Ht = exp(-0.5 * (t / sd_t).^2);

% Reshape filter correctly
Ht = reshape(Ht,size(St));

% Apply the filter to the time-domain signal
StH = Ht .* St;