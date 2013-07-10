function [psi_uw,trust] = unwrap3d(psi_w, mag, mag_thresh)
% Unwrap 3D phase image by region growing
%
% [psi_uw,trust] = unwrap3d(psi_w, mag, mag_thresh)
%
% ARGS:
% psi_w      = 3D phase-wrapped data
% mag        = 3D magnitude data
% mag_thresh = magnitude threshold to create mask
%
% RETURNS:
% psi_uw     = unwrapped 3D phase image
% trust      = trust region mask
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 07/06/2000 JMT Adapt from MEX_Unwrap2D
%          04/10/2001 JMT Add M-file wrapper
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
%
% REFS   : Based on ideas in Wei Xu and Ian Cumming
%          "A Region Growing Algorithm for InSAR Phase Unwrapping".
%          Proceedings of the 1996 IEEE International Geoscience and Remote Sensing Symposium.
%          IGARSS'96, pp. 2044-2046, Lincoln, USA, May. 1996. 

[psi_uw,trust] = MEX_Unwrap3D(psi_w, mag, mag_thresh);
