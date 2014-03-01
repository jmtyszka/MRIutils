function Ns = spinspervoxel(B0, d)
% Spins contributing to detected magnetization at a given field and voxel dimension
% - assumes water at 37 degC, 100% water voxel.
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 2014-02-28 JMT From scratch
%
% Copyright 2014 California Institute of Technology
% All rights reserved.

% Avagadro's Number (molecules per mole)
Na = 6.0221413e23;

% Molecular mass of water (g/mol)
M = 18;

% Mass density of water at 37C (kg/m^3)
Dm = 1000;

% H20 1H spins per cubic meter at 37C (molecules per m^3)
Ds =  Dm * 1e3 / M * Na * 2;

% Energy difference (J) between spin-1/2 states at 37C
dE = gamma_1H * B * h;
