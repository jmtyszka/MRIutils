function sm = movmed(s,k)
% SYNTAX: sm = movmed(s,k)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 10/08/2007 JMT Rewrite from memory
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

% Force row vector
s = s(:)';

% Get size and make space for filtered vector
n = length(s);
sm = zeros(size(s));

% Round up to next odd number
kk = fix(k/2)*2+1;
if kk ~= k
  fprintf('Rounding kernel size to %d\n',kk);
end

% Half-size of filter
hk = fix(kk/2);

for xc = 1:n
  
  % Start and end points of kernel
  m0 = xc-hk;
  m1 = xc+hk;

  % Clamp to vector limits
  if m0 < 1; m0 = 1; end
  if m1 > n; m1 = n; end
  
  % Add median of kernel to return vector
  sm(xc) = median(s(m0:m1));
  
end
