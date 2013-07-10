function pngstack(pngroot, pngdir, s)
% Write a 3D matlab matrix as a PNG stack
%
% pngstack(pngroot, pngdir, s)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 01/24/2001 From scratch
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

if nargin < 2
  help pngstack
  return;
end

% Create the directory if necessary
if ~exist(fullfile(pngroot,pngdir),'dir')
  mkdir(pngroot, pngdir);
end

nz = size(s,3);

% Robust scale of s to range 0..1
minmax = robustrange(s, [25 99.5]);
s = (s - minmax(1)) / (minmax(2) - minmax(1));

for z = 1:nz
  filename = sprintf('%s\\%s\\i%03d.png',pngroot,pngdir,z);
  imwrite(squeeze(s(:,:,z)), filename, 'png');
end