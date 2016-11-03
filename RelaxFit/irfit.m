function [M0, T1, alpha] = irfit(Mz, TI, modflag)
% [M0, T1, alpha] = irfit(Mz, TI, modflag)
%
% Fit the IR recovery equation to Mz(TI)
%
% Mz(TI) = M0 * (1 + E1 * (alpha - 1))
%
% where E1    = exp(-TI/T1)
%       Mz(0) = alpha * M0
%
% x = [M0 alpha T1]
%
% ARGS:
% Mz = Mz(TI) vector
% TI = Inversion time vector (ms)
% modflag = 0 if Mz is signed, 1 if |Mz| is provided
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 11/09/2000 From scratch
%          09/06/2001 Update for use with T1 mapping
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
options.TolX = 1e-3;
options.TolFun = 1e-3;

% Initial guess at parameters
% Guess T1 from TI for the minimum |Mz|
[minMz, imin] = min(abs(Mz));
x0 = [max(abs(Mz)) -1 TI(imin)];
xmin = [0 -1 0];
xmax = [Inf 1 Inf];

% Fire up the curve fitting algorithm
if modflag
  xfit = lsqcurvefit('lsq_absircontrast', x0, TI, Mz, xmin, xmax, options);
else
  xfit = lsqcurvefit('lsq_ircontrast', x0, TI, Mz, xmin, xmax, options);
end

% Return the optimized parameters
M0    = xfit(1);
alpha = xfit(2);
T1    = xfit(3);
