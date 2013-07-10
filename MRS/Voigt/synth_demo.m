function synth_demo
%
% synth_demo
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 4/28/00 Start from scratch

n    = 256;
bw   = 400;  % Hz
cf   = 64;   % MHz
df   = -130; % Hz
T    = 37.0; % degC
sd_n = 0.05; % SD of Gaussian white noise
sd_b = 0;    % SD of baseline noise

[f, s] = synth_mrs(n, cf, df, bw, T, sd_n, sd_b);

plot(f, real(s), f, imag(s)); set(gca, 'XDir', 'reverse');

