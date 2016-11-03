function model_fit
% Fit a model spectrum of four Voigt resonances to
% a synthetic spectrum. The baseline is refined
% by iterating on the fitting and baseline estimation.
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 4/28/00 Start from scratch
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

% Spectrum parameters
n    = 512;
bw   = 400;  % Hz
cf   = 64;   % MHz
df   = -130; % Hz
T    = 37.0; % degC
sd_n = 0.02; % Normal Noise SD
sd_b = 0.5;  % Baseline noise SD

% Create the synthetic spectrum
[f, s_expt] = synth_mrs(n, cf, df, bw, T, sd_n, sd_b);

% Baseline esimate
b_est = zeros(1,n);

% Initial parameter guesses
I0     = ones(1,4);
f0     = model_f0(T);
gL0    = 0.05 * ones(1,4);
gD0    = 0.05 * ones(1,4);
phi0   = zeros(1,4);

x_est = [I0 f0 gL0 gD0 phi0];

% Iterative baseline refinement
for itt = 1:3
  [s_est, b_est, x_est] = refine_fit(f, s_expt, b_est, x_est, T);
end

% Plot the fit result

title('Best Fit Model Spectrum');
subplot(3,2,1), plot(f, real(s_expt), f, real(s_est + b_est));
subplot(3,2,2), plot(f, imag(s_expt), f, imag(s_est + b_est));

% Fitted spectrum and baseline
subplot(3,2,3), plot(f, real(s_est), f, real(b_est));
subplot(3,2,4), plot(f, imag(s_est), f, imag(b_est));

% Residuals
subplot(3,2,5), plot(f, real(s_expt - s_est - b_est));
subplot(3,2,6), plot(f, imag(s_expt - s_est - b_est));
