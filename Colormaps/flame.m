function rgb = flame(n)
% Classic black-purple-red-orange-yellow colormap
%
% cmap = flame(n)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 07/18/2005 JMT From doppler.m (JMT)
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2005-2006 California Institute of Technology.
% All rights reserved.
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
if nargin < 1; n = 128; end

% Round n to power of 2
n = 2 ^ (round(log(n)/log(2)));

% Hue increases linearly from 0.75 to 1, then 0 to 0.25
h = mod(linspace(0.75, 1.25, n), 1);

% Saturation decreases as power law
s = linspace(1, 0, n) .^ 0.5;

% Value increases as power law
v = linspace(0, 1, n) .^ 0.5;

% Covert to rgb
hsv = [h(:) s(:) v(:)];
rgb = hsv2rgb(hsv);

