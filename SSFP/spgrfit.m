function [M0,T1,T2s,Sfit,resnorm] = spgrfit(S,TR,TE,alpha)
% [M0,T1,T2s,Sfit,resnorm] = spgrfit(S,TR,TE,alpha)
%
% Fit the ideal SPGR equation to a series of signal measurements S[TE,TR,alpha]
%
% ARGS :
% S     = vector of signal values [1 x N]
% TR    = vector of TR values (ms) for S[]
% TE    = vector of TE values (ms) for S[]
% alpha = vector of flip angles (degrees) for S[]
%
% RETURNS :
% M0      = equilibrium Mz (AU)
% T1      = T1 estimate (ms)
% T2s     = T2* estimate (ms)
% Sfit    = fitted signal estimate (AU)
% resnorm = squared 2-norm of the residual vector
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 2/14/2002 From scratch
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

% Flatten vectors
S = S(:);
TR = TR(:);
TE = TE(:);
alpha = alpha(:);

% Physiological initial guess for [T1 T2s M0]
x0 = [400 20 S(1)];

% Physiological constraints on [T1 T2s M0]
lb = [100 0 0];
ub = [1000 100 Inf];

% Get default fit options
opts = optimset('lsqnonlin');
opts.TolFun = 1e-9;
opts.TolX   = 1e-9;

% Do the fit
[x,resnorm] = lsqnonlin('spgr_err',x0,lb,ub,opts,S,TR,TE,alpha);

% Extract results
T1  = x(1);
T2s = x(2);
M0  = x(3);

% Calculate best fit function values
Sfit = spgreq(TR,TE,alpha,T1,T2s,M0);
