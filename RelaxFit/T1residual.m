function f = T1residual(x,xdata,ydata,mag,ncomps)
% Return difference between IR decay function
% calculated from x and xdata and the experimental
% decay in ydata as a sum of squared differences.
% mag is a flag for absolute signal calculation
% ncomps is the number of T1 components to be fitted
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
f = T1func(x,xdata,mag,ncomps) - ydata;

% Apply constraints
% scale = 1;
% for c = 1:ncomps
%   this_M0 = x(2*c-1);
%   this_T1 = x(2*c);
%   scale = scale * (1+exp(-this_T1)) * (1+exp(-this_M0));
% end
%
% f = f * scale;
