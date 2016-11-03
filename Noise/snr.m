function [sn, sd_n] = snr(s)
% Estimate the SNR of an N-D image
%
% USAGE : [sn, sd_n] = snr(s)
%
% ARGS :
% s = N-D scalar magnitude image
%
% RETURNS :
% sn   = SNR of image from 95th percentile signal
% sd_n = robust noise sd estimate (using MAD of detail coeffs)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 08/18/2005 JMT From scratch
%          03/20/2014 JMT Update comments
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

% Get the 95th percentile signal
s95 = percentile(s,95);

% Estimate the noise SD from the MAD of the detail coefficients of a
% wavelet decomposition
sd_n = noisesd(s);

% SNR estimate from 95th percentil signal and wavelet noise
sn = s95 / sd_n;
