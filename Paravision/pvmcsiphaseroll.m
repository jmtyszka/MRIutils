function kr = pvmcsiphaseroll(k,info)
% kr = pvmcsiphaseroll(k,info)
%
% Apply the phase rolls from the reco file (RECO_rotate) as
% linear phasings to a 3D CSI k-space.
%
% ARGS :
% k    = 3D complex k-space data (kf,kx,ky)
% info = info structure for Paravision dataset (info.recorot[])
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 01/07/2004 JMT Adapt from dtiphaseroll.m (JMT)
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2004-2006 California Institute of Technology.
% All rights reserved.

% Grab k-space dimensions
[nkf,nkx,nky] = size(k);

% k-space coordinate vectors for each dimension
kf = ((1:nkf)-1) - nkf/2;
kx = ((1:nkx)-1) - nkx/2;
ky = ((1:nky)-1) - nky/2;

% Normalized k-space coordinate grids
[kfg,kxg,kyg] = ndgrid(kf,kx,ky);

% Setup fractional offsets in each dimension
ff = 0.5;
fx = info.recorot(2);
fy = info.recorot(3);

% Generate combined linear phase function
phi = exp(-2 * pi * i * (ff * kfg + fx * kxg + fy * kyg));

% Apply phase functions
kr = k .* phi;