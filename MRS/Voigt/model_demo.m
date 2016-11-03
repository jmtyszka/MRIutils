function model_demo
% model_demo
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 4/28/00 Start from scratch
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

n = 1024;

BW = 400;  % Hz
CF = 64;   % MHz
DF = -130; % Hz

fmax = (BW / 2 - DF) / CF;
fmin = (-BW / 2 - DF) / CF;

df = (fmax - fmin) / (n-1);

f = fmin:df:fmax;

I = [1 0.5 0.5 4];
f0 = [2.0 3.0 3.2 4.7];
gL = [0.05 0.05 0.05 0.05];
gD = [0.05 0.05 0.05 0.05];
phi = [0 0 0 0];

s = model_mrs(f, I, f0, gL, gD, phi);

plot(f, real(s), f, imag(s)); set(gca, 'XDir', 'reverse');

