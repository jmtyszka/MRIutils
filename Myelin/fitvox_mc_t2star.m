function res = fitvox_mc_t2star(TE, S)
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

% Operational flags
verbose = 0;

%% Estimate and correct B0 offset from early echoes (first 16)

% Odd and even echo times (ms)
TE_odd  = TE(1:2:end)';
TE_even = TE(2:2:end)';

% Extract odd and even echo complex signal
S_odd  = S(1:2:end);
S_even = S(2:2:end);

% Odd and even echo phase angles (radians)
% Unwrap phase before regression
phi_odd = unwrap(angle(S_odd));
phi_even = unwrap(angle(S_even));

% Quick linear regression of phase
n_max = 8;
[phi0_odd,  dphi_odd]  = lr(TE_odd(1:n_max),  phi_odd(1:n_max));
[phi0_even, dphi_even] = lr(TE_even(1:n_max), phi_even(1:n_max));

% Phase corrections for each echo train
phi_corr_odd  = TE_odd  * dphi_odd  + phi0_odd;
phi_corr_even = TE_even * dphi_even + phi0_even;

% Save mean phase slope as dB0 (Hz)
dB0 = (dphi_odd + dphi_even)/2;

% Apply phase corrections, take real part (imag part should be zero)
% S_odd  = real(S_odd  .* exp(-1i * phi_corr_odd));
% S_even = real(S_even .* exp(-1i * phi_corr_even));
S_odd  = abs(S_odd);
S_even = abs(S_even);

% Phase corrected decay
S_0 = [S_odd(:)'; S_even(:)'];
S_0 = S_0(:);

% Load observed data into optimization parameter structure
pars.TE = TE;
pars.S  = S_0;

% Parameter estimates
oes = 1; % Odd-even scale factor (applied to even echo train)

rho = [S_0(1)/5 S_0(1)/2 S_0(1)/2];
T2  = [10 35 70]; % ms

% Initial parameter vector (guess)
X_0 = [oes rho T2];

% Upper and lower bounds on variables
lb = [0   0   0   0   5   30  60];
ub = [Inf Inf Inf Inf 15  40  80];

% Setup optimization parameters
opts = optimset('lsqnonlin');
opts.Display = 'off';

% Optimize model fit
[X_fit, resnorm] = lsqnonlin('costfn_mc_t2star', X_0, lb, ub, opts, pars);

% Extract optimized parameters of interest
res.rho     = X_fit(2:4);
res.T2      = X_fit(5:7);
res.mwf     = res.rho(1) / sum(res.rho);
res.resnorm = resnorm;
res.dB0     = dB0;
