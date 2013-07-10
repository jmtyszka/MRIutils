function [y, sd_n] = normnoise(x)
%
% Normalize the noise sd in a 2D image. Noise estimation
% by wavelet decomposition to first level.
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 11/30/2000 From scratch

% Estimate the noise sd
sd_n = noisesd(x);

% Normalize the noise
y = x / sd_n;
