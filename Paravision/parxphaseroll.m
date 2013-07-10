function kr = parxphaseroll(k,info)
% kr = parxphaseroll(k,info)
%
% Apply the phase rolls from the reco file (RECO_rotate) as
% linear phasings to a 3D k-space.
%
% ARGS :
% k    = 3D complex k-space data
% info = info structure for Paravision dataset (info.recorot[])
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 07/17/2002 From scratch
%
% Copyright 2002-2006 California Institute of Technology.
% All rights reserved.

% Grab k-space dimensions
[nkx,nky,nkz] = size(k);

% k-space coordinate vectors for each dimension
kx = ((1:nkx)-1) - nkx/2;
ky = ((1:nky)-1) - nky/2;
kz = ((1:nkz)-1) - nkz/2;

% Normalized k-space coordinate grids
[kxg,kyg,kzg] = ndgrid(kx,ky,kz);

% Generate combined linear phase function

switch info.ndim
  case 2
    fx = info.recorot(1,1);
    fy = info.recorot(1,2);
    fz = 0.0;
  case 3
    fx = info.recorot(1);
    fy = info.recorot(2);
    fz = info.recorot(3);
end

phi = exp(-2 * pi * i * (fx * kxg + fy * kyg + fz * kzg));

% Apply phase functions
kr = k .* phi;




