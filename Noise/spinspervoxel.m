function Ns = spinspervoxel(B, d)
% Spins contributing to detected magnetization at a given field and voxel dimension
% - assumes water at 37 degC, 100% water voxel.
%
% ARGS:
% B = field strength in Tesla
% d = voxel dimension in mm
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 2014-02-28 JMT From scratch
%
% Copyright 2014 California Institute of Technology
% All rights reserved.

% Default arguments
if nargin < 1; B = 3.0; end
if nargin < 2; d = 1.0; end

% Avagadro's Number (molecules per mole)
Na = 6.0221413e23;

% Planck's constant (m^2.kg/s)
h = 6.62606957e-34;

% Boltzmann constant
k = 1.3806488e-23;

% Temperature in Kelvin
T = 37.0 + 273.1;

% Molecular mass of water (g/mol)
M = 18;

% Mass density of water at 37C (kg/m^3)
Dm = 1000;

% H20 1H spins per cubic meter at 37C (molecules per m^3)
Ds =  Dm * 1e3 / M * Na * 2;

% Lamor frequency (Hz)
f0 = GAMMA_1H * B / (2*pi);

% Energy difference (J) between spin-1/2 states at 37C
dE = h * f0;

% Ratio of high to low energy state populations from Boltzmann dist
R = exp(-dE / (k * T));

% Fractional difference in populations (N_low - N_high) / (N_tot)
dP = (1-R) / (1+R);

% Spins per voxel contributing to signal
Ns = dP * Ds * (d * 1e-3)^3;

fprintf('Lamor frequency              : %0.3f MHz\n', f0 / 1e6);
fprintf('Fraction of detectable spins : %0.3f ppm\n', dP * 1e6);
fprintf('Spins contributing to signal : %0.3g\n', round(Ns));

