function psi0 = unwrap2d(psi, mag, magth)
% Phase unwrap a 2D image using a seed fill within a mask
%
% psi0 = unwrap2d(psi, mag, magth)
%
% ARGS:
% psi   = wrapped 2D phase image
% mag   = 2D magnitude images
% magth = magnitude threshold (same units as mag[])
%
% RETURNS:
% phi = unwrapped 2D phase image
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 06/23/2000 JMT Adapt from original BIC_Unwrap2D.m
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

% Call the MEX function
psi0 = MEX_Unwrap2D(psi, mag, magth);
