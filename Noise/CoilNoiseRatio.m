function S = CoilNoiseRatio
% S = CoilNoiseRatio
% 
% Calculate sample noise to coil noise ratio for ranges of B0 and sample radius
%
% AUTHOR : Mike Tyszka
% PLACE  : Caltech BIC
% DATES  : 06/17/2002 From scratch
% REFS   : Mansfield and Morris

% log range of B0 to consider
logB = -2:0.2:1;

% B0 range in Tesla
B = 10.^logB;

% Corresponding 1H frequency range in Hz
f = 4.2e6 * B;

% log object radius range to consider
logR = -3:0.1:1;

% Radius range in meters
R = 10.^logR;

% Create coordinate grid
[allf, allR] = meshgrid(R,f);

% Calculate sample noise / coil noise ratio
S = allf.^2 .* allR.^2 ./ sqrt(allf.^2 * allR.^3 + A * f.^0.5);

% Contour plot of SNR 
contour(allf,allR,S);