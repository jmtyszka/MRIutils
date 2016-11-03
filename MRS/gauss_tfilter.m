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

% Generate the time-domain Gaussian filter
sd_w = 2 * pi * FWHM / sqrt(8 * log(2));
sd_t = 1/sd_w;
Ht = exp(-0.5 * (t / sd_t).^2);

% Reshape filter correctly
Ht = reshape(Ht,size(St));

% Apply the filter to the time-domain signal
StH = Ht .* St;
