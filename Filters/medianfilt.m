function y = medianfilt(x, w)
%
% y = medianfilt(x, w)
%
% Median filter x using a w sample kernel
%
% ARGS:
% x = vector of uniformly sampled values
% w = filter kernel width [3]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte, CA
% DATES  : 05/31/00 Add index range
%          06/01/00 Remove index range
%          08/09/00 Add defaults and syntax message
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

if nargin < 1
   fprintf('SYNTAX: y = medianfilt(x,w)\n');
   return;
end

% Default kernel width of 3 samples
if nargin < 2
   w = 3;
end

nx = length(x);

% Half the kernel width rounded down
hk = floor(w/2);

p0 = (1:nx) - hk;
p1 = (1:nx) + hk;

% Keep start and end points within bounds
p0(p0 < 1) = 1;
p1(p1 > nx) = nx;

for p = 1:nx
   y(p) = median(x(p0(p):p1(p)));
end
