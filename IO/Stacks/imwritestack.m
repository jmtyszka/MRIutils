function imwritestack(s, stackdir, imform)
% Write out a 3D scalar matrix as a stack of images
%
% imwritestack(s, stackdir, imform)
%
% ARGS :
% s        = 3D scalar image
% stackdir = stack subdirectory of current directory
% imform   = image format (same as imwrite) = 'png','tif', etc
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 07/26/2001 JMT Adapt from pngstack.m
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2001-2006 California Institute of Technology.
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

% Get z size
nz = size(s,3);

% Create the destination directory if necessary
if ~exist(stackdir, 'dir')
  mkdir(stackdir);
end

% Find robust data limits
lims = robustrange(s,[5 99]);

% Normalize data range
s = (s - lims(1)) / diff(lims);

% Write out image stack
for z = 1:nz
  fname = sprintf('%s\\i%04d.%s', stackdir, z, imform);
  imwrite(squeeze(s(:,:,z)), fname, imform);
end
