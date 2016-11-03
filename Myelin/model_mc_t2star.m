function S = model_mc_t2star(X, TE)
% Full T2star decay from model parameters
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

% Parameter vector organization:
% [oes rho_1 rho_2 T2_1 T2_2]

% Odd and even echo times (ms)
TE_even = TE(2:2:end);
TE_odd  = TE(1:2:end);

% Unpack parameters
oes    = X(1); % Odd-even echo scale factor (apply to even echo train)
rho_1  = X(2);
rho_2  = X(3);
rho_3  = X(4);
T2_1   = X(5);
T2_2   = X(6);
T2_3   = X(7);

% Odd and even echo signals
S_odd  = rho_1*exp(-TE_odd/T2_1) + rho_2*exp(-TE_odd/T2_2) + rho_3*exp(-TE_odd/T2_3);
S_even = rho_1*exp(-TE_even/T2_1) + rho_2*exp(-TE_even/T2_2) + rho_3*exp(-TE_even/T2_3);
S_even = S_even * oes;

% Full decay (column vector)
S = [S_odd(:)'; S_even(:)'];
S = S(:);
