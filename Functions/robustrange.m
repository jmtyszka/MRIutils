function minmax = robustrange(s, plim, ns)
% Calculate a percentile range for N-D data
%
% minmax = robustrange(s, plim, ns)
%
% Calculate the robust range of s[] using plim(1,2)
% as the minimum and maximum percentile range.
% ns = number of samples to take (default is n/10 and < 1000)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte CA
% DATES  : 04/24/2001 JMT Adapt from MEPSI_RobustRange.m
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

if isempty(s)
  minmax = [0 1];
  return
end

% Flatten s
s = s(:);

% Default args
if nargin < 2; plim = [10 99]; end
if nargin < 3; ns = min([1000 length(s)/10]); end

if ns > length(s)
  ns = length(s);
end

% Random sample of s
isamp = fix(rand(1, fix(ns)) * length(s)) + 1;
ssamp = s(isamp);

% Sort the sample
ns = length(ssamp);
ssort = sort(ssamp);

% Find the index in the sorted vector of the minimum percentile
imin = round(plim(1)/100 * ns);
if (imin < 1); imin = 1; end

% Ditto for the maximum
imax = round(plim(2)/100 * ns);
if (imax > ns); imax = ns; end

% Return the values of ss[] at these indices
minmax = [ssort(imin) ssort(imax)];
