function f = model_ppm(n, cf, df, bw)
%
% Calculate the ppm scale for a spectrum
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 4/28/00 Start from scratch

% Scale limits in ppm
fmax = (bw / 2 - df) / cf;
fmin = (-bw / 2 - df) / cf;

% Spectrum step in ppm
df = (fmax - fmin) / (n-1);

% Create the ppm scale vector
f = fmin:df:fmax;
