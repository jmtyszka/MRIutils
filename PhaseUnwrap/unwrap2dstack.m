function [psi_uw, mask] = unwrap2dstack(psi_w, mag)
% Phase unwrap a 2D stack of images by 2D region growing
%
% [psi_uw, mask] = unwrap2dstack(psi_w, mag)
%
% ARGS:
% psi  = wrapped 2D stack of phase images
% mask = binary mask for each phase image
%
% RETURNS:
% phi = unwrapped 2D stack of phase images
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 06/16/2000 JMT Implement for first time
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2000-2006 California Institute of Technology.
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

nz = size(psi_w,3);

% Make space for the mag mask
mask = zeros(size(psi_w));
psi_uw = zeros(size(psi_w));

for z = 1:nz

  % Estimate the noise from the bottom left corner of this slice
  Sn = mag(1:8,1:8);
  sd_n = median(abs(Sn(:))) / 0.6745;

  % Call the MEX function
  [psi_uw(:,:,z), mask(:,:,z)] = ...
      MEX_Unwrap2D(psi_w(:,:,z), mag(:,:,z), 2 * sd_n);
  
end

