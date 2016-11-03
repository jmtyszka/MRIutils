function d = cohens_d(x,y)
% Calculate Cohen's d effect size between two groups
%
% USAGE : d = cohens_d(x,y)
%
% AUTHOR : Mike Tyszka
% PLACE  : Caltech
% DATES  : 07/30/2011 JMT From scratch
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

% If x and y are matrices, d is calculated for each column
nx = size(x,1);
ny = size(y,1);

% Calculate mean over columns
mx = mean(x);
my = mean(y);
    
% var() normalizes by n-1
varx = var(x);
vary = var(y);

% Pooled sd
s = sqrt(((nx-1) * varx + (ny-1) * vary) / (nx + ny));

% Cohen's d for each column
d = (mx - my) ./ s;
