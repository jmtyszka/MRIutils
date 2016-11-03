function [StH, Ht] = exp_tfilter(t,St,FWHM)
% Exponential time-domain filtering
%
% [StH, Ht] = exp_tfilter(t,St,FWHM)
%
% Generate and apply the time domain Exponential filter which
% has a given FWHM in the frequency domain.
%
% A Lorentzian from an exponetial with time constant T2
% has a FWHM in the frequency domain of 1 / (pi * T2)
% T2 in seconds, FWHM in Hz.
%
% Exponential:
% S(t) = exp(-a t)
%
% Lorentzian (Normalized to S(0) = 1):
%   S(w) = a / (a - i w)
%   Re(S(w)) = a^2 / (a^2 + w^2)
%   Im(S(w)) = a w / (a^2 + w^2)
% where w = 2 pi f
%
% ARGS :
% t    = time vector (seconds)
% St   = time domain signal
% FWHM = FWHM of frequency domain Lorentzian (Hz)
%
% RETURNS:
% StH  = filtered time domain signal
% Ht   = time domain filter function
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 02/26/2004 Adapt from linebroaden.m (JMT)
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

% Generate the time-domain Exponential filter
T2 = 2 / (2 * pi * FWHM);
Ht = exp(-t / T2);

% Reshape filter correctly
Ht = reshape(Ht,size(St));

% Apply the filter to the time-domain signal
StH = Ht .* St;
