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
