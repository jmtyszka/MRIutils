function sr = robustscale(s, newlims, plim)
% Percentile rescale N-D data
%
% sr = robustscale(s, newlims, plim)
%
% Rescale an image to the percentile limits specified.
% Clamp values outside of this range.
%
% ARGS:
% s       = nD scalar dataset
% newlims = destination image limits [0 1]
% plim    = optional percentile source limits [low hi] [5 95]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 10/24/2003 JMT Adapt from robustrange.m (JMT)
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

% Default arguments
if nargin < 1; return; end
if nargin < 2; newlims = [0 1]; end
if nargin < 3; plim = [5 95]; end

% Get percentile limits
lims = robustrange(s,plim);

% Intensity transform
sr = (s - lims(1)) / (diff(lims) + eps) * diff(newlims) + newlims(1);

% Clamp values
sr(sr < newlims(1)) = newlims(1);
sr(sr > newlims(2)) = newlims(2);
