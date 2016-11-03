function cmap = redblue(n)
% Signed red-blue colormap
%
% cmap = redblue(n)
%
% Generate a red-blue colormap with n levels for
% signed, zero-biased images.
% blue/white - blue - black - red - pink
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 09/28/2000 JMT From scratch
%          01/15/2003 JMT Update to color doppler type scale
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

% Default to 128 levels
if nargin < 1
  n = 128;
end

% Round n to power of 2
n = 2 ^ (round(log(n)/log(2)));

% Fractions of cmap
qn = fix(n/4);

% Quarter ramp
qramp_up = linspace(0,1,qn)';
qramp_dwn = linspace(1,0,qn)';

% Make space for the colormap
cmap = zeros(n, 3);

% Q1 blue-white to blue
Q1 = 1:qn;
cmap(Q1,1) = qramp_dwn * 0.9;
cmap(Q1,2) = qramp_dwn * 0.9;
cmap(Q1,3) = 1.0;

% Q2 blue to black
Q2 = Q1 + qn;
cmap(Q2,1) = 0.0;
cmap(Q2,2) = 0.0;
cmap(Q2,3) = qramp_dwn;

% Q3 black to red
Q3 = Q2 + qn;
cmap(Q3,1) = qramp_up;
cmap(Q3,2) = 0.0;
cmap(Q3,3) = 0.0;

% Q4 red to pink
Q4 = Q3 + qn;
cmap(Q4,1) = 1.0;
cmap(Q4,2) = qramp_up * 0.9;
cmap(Q4,3) = qramp_up * 0.9;
