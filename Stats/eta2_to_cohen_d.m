function [cohen_d, desc] = eta2_to_cohen_d(eta2)

% Convert eta2 to cohen's d.
%
% ARGS :
% eta2 = percent variance explained from ANOVA result (see anova_eta2.m)
%
% RETURNS :
% cohen_d : Cohen's d effect size
% desc    : Adjective associated with d 
%
% AUTHORS : Dan Kennedy and Mike Tyszka
% PLACE  : Caltech
% DATES  : 05/01/2012 From scratch
%          05/01/2012 Added descriptive return
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

cohen_d = 2*sqrt(eta2/(1-eta2));

% Adjective for effect size
% < 0.2      'negligible'
% 0.2 .. 0.5 'small'
% 0.5 .. 0.8 'medium'
% > 0.8      'large     

desc = 'negligible';

if cohen_d >= 0.2
  desc = 'small';
end

if cohen_d >= 0.5
  desc = 'medium';
end

if cohen_d >= 0.8
  desc = 'large';
end

