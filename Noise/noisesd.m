function sd_n = noisesd(x)
% Estimate the noise sd using wavelet decomposition and MAD of the detail coeffs
%
% USAGE: sd_n = noisesd(x)
%
% ARGS:
% x = N-D scalar magnitude MR image
%
% RETURNS:
% sd_n = robust noise SD estimate
% 
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 01/26/2001 JMT Extract from normnoise.m
%          01/17/2006 JMT M-Lint corrections
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

% Single-level wavelet decomposition of x
[~,cd] = dwt(x(:),'sym4');

% Estimate the noise sd using the MAD of the detail coefficients (cd)
sd_n = median(abs(cd(:) - median(cd(:)))) / 0.6745; 
