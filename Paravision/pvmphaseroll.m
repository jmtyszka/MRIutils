function kr = pvmphaseroll(k,info)
% kr = pvmphaseroll(k,info)
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
%          09/10/2007 JMT Move to PVM utilities toolbox
%
% Copyright 2002-2007 California Institute of Technology.
% All rights reserved.

% Grab k-space dimensions
[nkx,nky,nkz,ni] = size(k);

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
    fx = info.recorot(1,1);
    fy = -info.recorot(1,2);
    fz = -info.recorot(1,3);
  otherwise
    fprintf('Unsupported image dimensionality: %d\n', info.ndim);
    fx = 0;
    fy = 0;
    fz = 0;
end

fprintf('pvmphaseroll: Rolling by [%0.3f, %0.3f, %0.3f]\n', fx, fy, fz);

phi = exp(-2 * pi * 1i * (fx * kxg + fy * kyg + fz * kzg));

% Duplicate phase roll across all echo images
if ni > 1
  phi = repmat(phi,[1 1 1 ni]);
end

% Apply phase functions
kr = k .* phi;




