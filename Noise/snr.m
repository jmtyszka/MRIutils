function [sn, sd_n] = snr(s)
% Estimate the SNR of an N-D image
%
% USAGE : [sn, sd_n] = snr(s)
%
% ARGS :
% s = N-D scalar magnitude image
%
% RETURNS :
% sn   = SNR of image from 95th percentile signal
% sd_n = robust noise sd estimate (using MAD of detail coeffs)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 08/18/2005 JMT From scratch
%          03/20/2014 JMT Update comments
%
% Copyright 2005,2014 California Institute of Technology.
% All rights reserved.

% Get the 95th percentile signal
s95 = percentile(s,95);

% Estimate the noise SD from the MAD of the detail coefficients of a
% wavelet decomposition
sd_n = noisesd(s);

% SNR estimate from 95th percentil signal and wavelet noise
sn = s95 / sd_n;
