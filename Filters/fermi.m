function [H, x] = fermi(n, fr, fw)
% [H, x] = fermi(n, fr, fw)
%
% Return a 1D Fermi filter function
%
% ARGS:
% n  = number of filter points
% fr = fractional filter radius [0, 1] [0.5]
% fw = fractional filter transition width [0, 1] [0.05]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech Biological Imaging Center
% DATES  : 10/28/2003 JMT Adapt from fermi3.m (JMT)
%          03/22/2004 JMT Add tails argument
%          04/11/2014 JMT Remove tails argument, limit to positive x
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
if nargin < 1, n = 128; end
if nargin < 2, fr = 0.5; end
if nargin < 3, fw = 0.05; end

% Construct a normalized coordinate vector [-0.5, 0.5]
x = linspace(-0.5,0.5,n);

% Construct 1D Fermi filter vector
H = 1 ./ (1 + exp((x - fr)/fw));
