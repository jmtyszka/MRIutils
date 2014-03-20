function B0 = WhichB0
% Estimate optimal B0 for a given experiment
%
% B0 = WhichB0
%
% Given the following:
%   - Contrast
%   - Anatomic region
%   - Required spatial resolution
%   - Minimum SNR
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 04/07/2000 JMT From scratch
%          03/20/2014 JMT Update comments
%
% This file is part of MRIutils.
%
%     MRIutils is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     MRIutils is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with MRIutils.  If not, see <http://www.gnu.org/licenses/>.
%
% Copyright 2000,2014 California Institute of Technology.

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
