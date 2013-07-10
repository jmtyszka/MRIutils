function [sn,sd_n] = snr(s)
% Estimate the SNR of an image.
%
% SYNTAX : [sn,sd_n] = snr(s)
%
% Estimates noise sd from the MAD of the detail coefficients of a wavelet
% decomposition of the image.
%
% ARGS:
% s = nD image
%
% RETURNS:
% sn = signal-to-noise ratio of image
% sd_n = noise sd
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATE   : 06/17/2002 From scratch
%          10/22/2009 Add comments

% Flatten image and count voxels
s = s(:);
n = length(s);

% Estimate sample noise sd
sd_n = noisesd(s);

% Find 95 percentile signal intensity
p95_s = percentile(s,95);

% Estimate SNR
sn = p95_s / sd_n;

fprintf('\nIMAGE SNR ESTIMATE\n\n');
fprintf('  Noise sd              : %0.3g\n', sd_n);
fprintf('  Image 95th Percentile : %0.3g\n', p95_s);
fprintf('  SNR                   : %0.1f\n\n', sn);
