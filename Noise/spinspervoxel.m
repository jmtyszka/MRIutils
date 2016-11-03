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
M = 18.01528;

% Density of pure water at 37C (kg/m^3)
Dm = 993;

% H20 1H spins per cubic meter at 37C (1H nuclei per m^3)
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

