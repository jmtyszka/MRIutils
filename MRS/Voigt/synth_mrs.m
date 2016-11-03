function [f, s_e, x_e] = synth_mrs(n, cf, df, bw, T, sd_n, sd_b)
% Generate a synthetic long TE 1H brain spectrum
%
% n     = number of points
% cf    = central frequency of spectrum in MHz
% df    = frequency offset to center of spectrum in Hz
% bw    = spectral bandwidth in Hz
% T     = sample temperature in degC
% sd_n  = sd of Gaussian noise in AU
% sd_b  = sd of baseline noise
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

f = model_ppm(n, cf, df, bw);
f0 = model_f0(T);

I = [1 0.5 0.5 2];
gL = [0.05 0.05 0.05 0.05];
gD = [0.05 0.05 0.05 0.05];
phi = [1 1 -0.5 0];

x_e = [I f0 gL gD phi];

% Generate the four resonance complex spectrum
s_e = model_mrs(f, I, f0, gL, gD, phi);

% Add a smoothed random baseline
b = synth_base(n, sd_b);

% Complex noise
noise = mrs_noise(n, sd_n);

s_e = s_e + b + noise;
