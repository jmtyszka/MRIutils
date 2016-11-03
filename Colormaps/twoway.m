function cmap = twoway(n)
% Signed red-white-blue colormap
%
% cmap = twoway(n)
%
% Generate a red-blue colormap with n levels for
% signed, zero-biased images.
% blue - pale blue - white - pink - red
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 07/01/2004 JMT Adapt from doppler.m (JMT)
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
hn = fix(n/2);

% Quarter ramp
hramp_up = linspace(0,1,hn)';
hramp_dwn = linspace(1,0,hn)';

% Make space for the colormap
cmap = zeros(n, 3);

% H1 desaturate blue
H1 = 1:hn;
cmap(H1,1) = hramp_up;
cmap(H1,2) = hramp_up;
cmap(H1,3) = 1.0;

% Q2 blue to mid-gray
H2 = H1 + hn;
cmap(H2,1) = 1.0;
cmap(H2,2) = hramp_dwn;
cmap(H2,3) = hramp_dwn;
