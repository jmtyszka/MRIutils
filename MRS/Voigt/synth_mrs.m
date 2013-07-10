function [f, s_e, x_e] = synth_mrs(n, cf, df, bw, T, sd_n, sd_b)
%
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
