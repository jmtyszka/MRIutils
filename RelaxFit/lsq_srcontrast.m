function [F,J] = lsq_srcontrast(x, TR)
%
% lsqcurvefit function for SR contrast
%
% x = [A T1]
%
% F = A * (1 - exp(-TR/T1)) + C
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 11/09/2000 JMT From scratch
%          09/11/2003 JMT Update with DC component
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

A  = x(1);
T1 = x(2);
C  = x(3);

Q = exp(-TR/T1);
R = 1-Q;

F = A * R + C;

% Jacobian J(i,j) = d(F(i))/d(X(j))

n = length(F);
J = zeros(n,2);

J(:,1) = R;
J(:,2) = -A * TR/(T1*T1) .* Q;
J(:,3) = 1;
