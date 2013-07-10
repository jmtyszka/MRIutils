function snr = mrsnr
% snr = mrsnr
%
% Analytical estimate of SNR based on a comprehensive parameter set
% - relaxation
% - polarization
% - imaging parameters (TR,TE,BW,voxel size)
% - field inhomogeneity
% - pulse sequence
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 04/21/2005 JMT From scratch
% REFS   : Mansfield and Morris, 2nd edition, pp192
%          Abragam 1961 Chapter 3
%          Hoult and Lauterbur JMT 1979;34:425
%
% Copyright 2005 California Institute of Technology.
% All rights reserved.

% General physical constants
hbar = 1.0546e-34; % Plank's constant / 2pi in J s
kboltz = 1.3807e-23; % Boltzmann's constant in J/K
Nav = 6.02214199e23; % Avogadro's number

% Physical constants for 1H nucleus
Ispin = 0.5;
gamma_1H = 2.67522212e8; % Proton gyromagnetic ratio in rad/s/T;

% Experimental parameters
B0 = 3; % Magnetic flux density in Tesla

% Sample properties
Ts = 300; % Sample temp in Kelvin
N  = 1e3 / 18 * 2 * Nav; % Proton density in spins/(m^3)

% Basic polarization equation for M0
M0 = N * (gamma_1H * hbar)^2 * Ispin * (Ispin + 1) * B0 / (3 * kboltz * Ts)

return

% From Abragam
snr = K * eta * M0 / Fn * sqrt((mu0 * Q * w0 * Vc) / (4 * k * Tc * df));