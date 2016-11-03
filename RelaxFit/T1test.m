function T1test
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

% Number of T1 components
ncomps = 2;
mag = 1; % Use absolute signal for decay

% Underlying parameters
T1 = [500 800];
M0 = [500 0];
Noise = 50;

TI = 50:200:1600;

x0 = [M0' T1']';
x0 = x0(:);

% Call signed T1 IR function
Ms = T1func(x0,TI,0,ncomps);

% Add noise and take magnitude
N = Noise * (rand(size(Ms)) - 0.5);
Ms = Ms + N;

if (mag == 1)
   M = abs(Ms);
else
   M = Ms;
end

% Setup options for constrained optimization
options(1) = -1;

% Curve fit to IR decay
[x,options,lambda,hess] = leastsq('T1residual',x0,options,[],TI,M,mag,ncomps);
Mfit = T1func(x,TI,mag,ncomps);

subplot(2,1,1), plot(TI,Mfit,TI,M,'o');

fprintf('Absolute method\n\m');
for c = 1:ncomps
   fprintf('Component %d:\n',c);
   fprintf('M0 : %f (%f)\n', x(2*c-1), M0(c) );
   fprintf('T1 : %f (%f)\n', x(2*c)  , T1(c) );
end
