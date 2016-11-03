function [x, Mfit] = T1Fit(M, TI, ncomps, mag)
% T1 inversion recovery fit for one voxel
%
% [T1, M0] = T1Fit(M, TI, comps, Mag)
%
% M  : contains N magnitude signal samples
% TI : contains the N TIs corresponding to S
% ncomps : number of T1 components to fit
% mag : real data (=0) magnitude data (=1)
%
% Mz(t) = sum_i(M0i(1-E1i) + Mzi(0)E1i)
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

[nx,nTI] = size(M);

% Initial guesses
M0guess = M(nTI);
T1guess = mean(TI);

% Initial guess array
x0 = (ones(ncomps,1) * [M0guess T1guess])';
x0 = x0(:); % Flatten

% Iteration options
options(1) = -1;   % Full messages
options(7) = 1;    % Safeguarded cubic search
options(14) = 500*length(x0);

% Iterate
[x,options,lambda,hess] = leastsq('T1residual',x0,options,[],TI,M,mag,ncomps);
Mfit = T1func(x,TI,mag,ncomps);

