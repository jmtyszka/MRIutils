function pngstackrgb(filestub, s)
% pngstackrgb(filestub, s)
%
% Write a 3D RGB matlab matrix as a PNG stack
%
% ARGS:
% filestub = file stub for image files ( _%03d.png is added to complete the filename)
% s        = 3D spatial RGB volume (x,y,rgb,z)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte CA
% DATES  : 03/07/2001 JMT Adapt from pngstack.m
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

if nargin < 2; return; end

% Grab nz dimension
nz = size(s,4);

% Normalize s to RGB range 0..1
maxs = max(s(:));
mins = min(s(:));
s = (s - mins) / (maxs - mins);

% Write out the stack
for z = 1:nz
  filename = sprintf('%s_%03d.png',filestub,z);
  imwrite(squeeze(s(:,:,:,z)), filename, 'png');
end