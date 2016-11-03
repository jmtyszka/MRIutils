function cmap = hotmetal(n)
% Hot metal colormap
%
% cmap = hotmetal(n)
%
% Hot metal colormap runs through:
%   black
%   dark blue
%   purple
%   red
%   orange
%   yellow
%   white
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 09/27/2004 JMT Adapt from twoway.m (JMT)
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

% Round n to a multiple of 6
n = fix(n/6)*6;

% Fractions of cmap
n6 = fix(n/6);

% Ramps (sixth of range)
ramp_up = linspace(0,1,n6)';
ramp_dwn = linspace(1,0,n6)';

% Make space for the colormap
cmap = zeros(n, 3);

% black to blue
E1 = 1:n6;
cmap(E1,1) = 0.0;
cmap(E1,2) = 0.0;
cmap(E1,3) = ramp_up/2;

% blue to purple
E2 = E1 + n6;
cmap(E2,1) = ramp_up/2;
cmap(E2,2) = 0.0;
cmap(E2,3) = 0.5;

% purple to red
E3 = E2 + n6;
cmap(E3,1) = ramp_up/2 + 0.5;
cmap(E3,2) = 0.0;
cmap(E3,3) = ramp_dwn/2;

% red to orange
E4 = E3 + n6;
cmap(E4,1) = 1.0;
cmap(E4,2) = ramp_up/2;
cmap(E4,3) = 0.0;

% orange to yellow
E5 = E4 + n6;
cmap(E5,1) = 1.0;
cmap(E5,2) = ramp_up/2 + 0.5;
cmap(E5,3) = 0.0;

% yellow to white
E6 = E5 + n6;
cmap(E6,1) = 1.0;
cmap(E6,2) = 1.0;
cmap(E6,3) = ramp_up;
