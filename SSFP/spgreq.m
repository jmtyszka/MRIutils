function s = spgreq(TR,TE,alpha,T1,T2s,M0)
% s = spgreq(TR,TE,alpha,T1,T2s,M0)
%
% Signal magnitude at the echo time for a perfectly spoiled
% SPGR sequence.
%
% ARGS :
% TR    = repetition time vector (ms) (N x 1)
% TE    = echo time vector (ms) (N x 1)
% alpha = flip angle vector (degrees) (N x 1)
% T1    = T1 relaxation time (ms)
% T2s   = T2* relaxation time (ms)
% M0    = equilibrium magnetization (AU)
%
% RETURNS :
% s      = signal vector at (TR,TE,alpha) (AU) (N x 1)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 2/14/2002 From Mathematica working in SSFP.nb
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

alpha = alpha * pi / 180;
E1  = exp(-TR/T1);
E2s = exp(-TE/T2s);

% Full ideal SPGR equation
s = M0 .* (1 - E1) .* sin(alpha) ./ (1 - E1 .* cos(alpha)) .* E2s;
