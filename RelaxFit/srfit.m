function [A, T1, C, s_fit] = srfit(t,s,mode,options,x0)
% [A, T1, C, s_fit] = srfit(t,s,mode,options,x0)
%
% Fit the SR contrast equation to s(t)
%
% s(t) = A * (1 - exp(-t/T1)) + C
%
% ARGS:
% t = time points
% s = signal points at each time
% mode = fit mode = 'constrained' or 'unconstrained' ['unconstrained']
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

if nargin < 3 mode = 'constrained'; end
if nargin < 4
  options = optimset('lsqcurvefit');
  options = optimset(options,...
  'TolFun',1e-5,...
  'TolX',1e-5,...
  'Jacobian','on',...
  'Display','off');
end

% Initial guess if not supplied
if nargin < 5
  x0 = [max(s(:)) t(1) 0];
end

% Flatten vectors
t = t(:);
s = s(:);

nt1 = length(s);
nt2 = length(t);
if ~isequal(nt1, nt2)
  fprintf('Not enough TR values were provided (got %d expected %d)\n', nt2, nt1);
  return
else
  nt = nt1;
end

switch mode
  case 'constrained'
    % [A T1 C]
    xmin = [-Inf 0 0];
    xmax = [Inf Inf Inf];
  case 'unconstrained'
    xmin = [];
    xmax = [];
    options.LargeScale = 'off';
end

x_fit = lsqcurvefit('lsq_srcontrast', x0, t, s, xmin, xmax, options);

s_fit = lsq_srcontrast(x_fit, t);

A  = x_fit(1);
T1 = x_fit(2);
C  = x_fit(3);
