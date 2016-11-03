function [S0, T2] = mefit(ME, TE)
% [S0, T2] = mefit(ME, TE)
%
% Fit the T2 contrast equation:
%
%   ME(TE) = S0 * exp(-TE/T2)
%
% to the last dimension of an N-D matrix, S[]
%
% ARGS:
% ME = N-D matrix with echo time as final dimension
% TE = echo time vector for the final dimension
%
% RETURNS:
% S0 = S(TE=0) matrix
% T2 = T2 matrix in ms
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 09/06/2001 Adapt from irfit
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

options = optimset('lsqcurvefit');
options.Display = 'none';

x0   = [ME(1) min(TE)];
xmin = [0 0];
xmax = [Inf Inf];

x = lsqcurvefit('lsq_mecontrast', x0, TE, ME, xmin, xmax, options);

S0 = x(1);
T2 = x(2);

% Plot result and hold
% ME_fit = lsq_mecontrast(x, TE);
% plot(TE, ME, 'o', TE, ME_fit);
