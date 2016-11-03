function y = percentile(x, p)
% y = percentile(x, p)
%
% Calculate the p'th percentile of the vector x
%
% ARGS:
% x = array of values
% p = vector of percentiles to be calculated
%
% RETURNS:
% y = vector of percentiles corresponding to p
%
% AUTHOR  : Mike Tyszka, Ph.D.
% PLACE   : City of Hope, Duarte CA
% DATES   : 02/20/2001 From scratch
%           10/09/2001 Add support for multiple percentiles
%#realonly
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

% Flatten the vectors
x = x(:);
p = p(:);
n = length(x);

% Catch single point
if n < 2
  y = repmat(x(1),size(p));
  return
end

% Sort the vector
sx = sort(x);

% Find fractional percentile indices
inds = (n * p / 100) + 0.5;

% Keep index in bounds
inds(inds > n) = n;
inds(inds < 1) = 1;

% Interpolate percentile
y = interp1(1:n, sx, inds, '*linear');
