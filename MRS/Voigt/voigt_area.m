function Q = voigt_area(I0, gL, gD)
% Q = voigt_area(A, gL, gD)
%
% Estimates the [-Inf,Inf] integral of the real
% Voigt lineshape using Gaussian quadrature.
% Assumes no contribution to integral beyond
% 100 * max(gL,gD).
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope National Medical Center
% DATES  : 05/08/00 Continue from previous Matlab code by JMT
%          06/01/00 Use Matlab quad8 rather than user contrib gaussq
%                   Change upper limit to 100 * max(gL,gD)
%                   Back to gaussq - no itteration limit errors
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

p = 1e3 * max([gL gD]);

Q0 = I0 * gaussq('voigt_real', 0, p, [], [], gL, gD);

Q = real(2 * Q0);
