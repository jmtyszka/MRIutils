function Rrgb = composite(Argb, Brgb, qA, qB, cmode)
% Overlay two RGB transparent images using a given mode
%
% Rrgb = composite(Argb, Brgb, qA, qB, cmode)
%
% ARGS:
% Argb  = RGB image A
% Brgb  = RGB image B
% qA    = Opacity of image A
% qB    = Opacity of image B
% cmode = Compositing mode : 'normal', 'multiply', 'screen', 'lighten', 'darken'
%
% RETURNS:
% Rrgb  = Composited RGB image
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte CA
% DATES  : 02/21/2001 JMT From scratch
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2002-2006 California Institute of Technology.
% All rights reserved.
%
% This file is part of MRutils.
%
% MRutils is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% MRutils is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with MRutils; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

fname = 'composite';

% Default return
Rrgb = [];

% Check parameters
if nargin < 5
  cmode = 'normal';
end
if nargin < 4
  fprintf('SYNTAX : %s(Argb, Brgb, qA, qB, cmode)\n', fname);
  return
end

% Check opacities
if qA < 0 || qB < 0 || qA > 1 || qB > 1
  fprintf('%s: Transparencies must be in range 0..1\n',fname);
  return
end

% Check image dimensions
[nxA, nyA, ncA] = size(Argb);
[nxB, nyB, ncB] = size(Brgb);

if nxA ~= nxB || nyA ~= nyB
  fprintf('%s: Images must have the same dimensions\n', fname);
  return
end

if ncA ~= 3 || ncB ~= 3
  fprintf('%s: Images must be RGB (nx x ny x 3)\n', fname);
  return
end

% Normalize to doubles in range [0,1]
Argb = double(Argb);
Brgb = double(Brgb);
Argb = Argb / max(Argb(:));
Brgb = Brgb / max(Brgb(:));

switch lower(cmode)
case 'normal'
  Rrgb = qA * Argb + Brgb; % A transparently overlays B
case 'overlay'
  Rrgb = Brgb .* (Brgb + (2 * Argb .* (1 - Brgb)));
case 'multiply'
  Rrgb = qA * Argb + qB * Brgb + Argb .* Brgb;
case 'screen'
  Rrgb = Argb + Brgb - Argb .* Brgb;
case 'lighten'
  Rrgb = min(cat(3, qB * Brgb + Argb, qA * Argb + Brgb),[],3);
case 'darken'
  Rrgb = max(cat(3, qB * Brgb + Argb, qA * Argb + Brgb),[],3);
otherwise
  fprintf('%s: Unknown composite mode %s\n', fname, cmode);
  return
end

% Finally clamp RGB values to range 0..1
Rrgb(Rrgb > 1) = 1;
Rrgb(Rrgb < 0) = 0;