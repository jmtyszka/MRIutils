function s = imreadbytestack(sdir, sform, imform, zinds)
% Read in a stack of 2D byte images
%
% s = imreadbytestack(sdir, sform, imform, zinds)
%
% ARGS :
% sdir     = directory containing image stack
% sform    = filename format string (eg 'i.%03d.tif').
% imform   = image format (same as imwrite) = 'png','tif', etc
% zinds    = image index range to read
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 07/30/2001 JMT Adapt from imwritestack.m
%          08/02/2001 JMT Add support for image index range
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

% Defaults
if nargin < 4; zinds = [1 2]; end

% Calculate total number of images to read
nz = diff(zinds) + 1;

% Get image information from first image in requested stack
fname = sprintf(sform, zinds(1));
pname = [sdir '\' fname];
info = imfinfo(pname, imform);
xydims = [info.Height info.Width];

% Make uint8 space for stack
s = zeros(xydims);
s = uint8(s);
s = repmat(s,[1 1 nz]);

% Create a waitbar
hwb = waitbar(0);

for z = zinds(1):zinds(2)
  
  % Construct the full file path
  fname = sprintf(sform, z);
  pname = [sdir '\' fname]; 
  
  % Check for existance of file
  if exist(pname,'file')
    
    % Update matrix z index
    zc = z - zinds(1) + 1;
    
    % Update waitbar
    waitbar(zc/nz,hwb,sprintf('Loading %s',fname));
    
    % Load this slice
    s(:,:,zc) = uint8(imread(pname, imform));
    
  end
    
end

% Close the waitbar
close(hwb);