function s2 = medianqt(s)
% Decompose the 2D image s() by a factor of 2
%
% s2 = medianqt(s)
%
% Each quadtree node is the median of its branches
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 06/23/2000 JMT From scratch
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

[nrow, ncol] = size(s);

nrow2 = nrow/2;
ncol2 = ncol/2;

% Make space for new downsampled image
s2 = zeros(nrow2, ncol2);

for c = 1:ncol2

  % Extract the first column -> 2 x nrow
  colinds = 2 * (c-1) + (0:1) + 1;
  scol = s(:, colinds)';

  % Reshape scol() so that each quad forms a row -> 4 x nrow2
  scol = reshape(scol, 4, nrow2);

  % Find medians of the rows of scol()
  % This forms the c'th column of the downsampled data
  s2(:,c) = median(scol, 1)';

end
