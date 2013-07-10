function B0 = WhichB0
% B0 = WhichB0
%
% Given the following:
%   - Contrast
%   - Anatomic region
%   - Required spatial resolution
%   - Minimum SNR
% this function estimates an optimal B0 at which
% to perform the experiment.
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 4/7/00 Start from scratch

% The underlying MRI SNR equation
% The proportionality constant is set to 1

% Gamma for 1H nucleus
gamma = 4.2e7; % MHz/T

% Material susceptibility
chi = 1;

% Main field
B0 = 0:15;

% Temperature
T = 37.0 + 273.1; % K

% Coil parameters
Nc = 1;
Q = 1;
Veff = 1;

% Image matrix size
Nx = 128;
Ny = 128;
Nz = 128;

Na = 2;

% Voxel volume in m^3
V = 100e-6^3;

% Frequency encoding bandwidth
% Assume that this must scale with B0
BW = B0;

% Basic SNR equation
snr = sqrt(gamma * chi^2 * B0.^3 / T * ...
	Nc * Q / Veff * ...
	Na ./ BW) * V;

plot(B0,snr);
