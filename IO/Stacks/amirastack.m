function amirastack(dirname,subdirname,s,vsize)
% Export a dataset in Amira TIFF Stack format
%
% amirastack(dirname,subdirname,s,vsize)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 07/26/2002 JMT From scratch
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

% Argument checks
if nargin < 3
  fprintf('USAGE: amirastack(dirname,subdirname,s,vsize)\n');
  return
end

if nargin < 4
  vsize = [1 1 1];
end

% Strip the trailing \ from the dirname
dlen = length(dirname);
if isequal(dirname(dlen),filesep)
  dirname(dlen) = [];
end

% Expand directory name '.'
if isequal(dirname,'.')
  dirname = pwd;
end

% Grab z size
nz = size(s,3);

% First write the TIFF stack to the subdirectory of the main directory
tiffstack(dirname, subdirname, s);

% Now create an Amira TIFF Stack info file in the main directory
atsname = [dirname filesep subdirname '.ats'];
fd = fopen(atsname,'w');
if fd < 0
  fprintf('Could not open %s to write\n', atsname);
  return
end

fprintf(fd, '# Amira Stacked Slices\n\n');
fprintf(fd, '# Generated automatically by amirastack.m:\n');
fprintf(fd, '# Author : Mike Tyszka, Ph.D.\n');
fprintf(fd, '# Place  : Caltech Biological Imaging Center\n');
fprintf(fd, '# Date   : %s\n\n', datestr(now));
fprintf(fd, '# Directory where image files reside\n');
%fprintf(fd, 'pathname \"%s\"\n\n', [dirname filesep subdirname]);
fprintf(fd, 'pathname \"%s\"\n\n', subdirname);
fprintf(fd, '# Pixel size in x- and y-direction\n');
fprintf(fd, 'pixelsize %0.3f %0.3f\n\n', vsize(1), vsize(2));

% Write out image list
fprintf(fd, '# Image list with z-positions\n');
for zc = 1:nz
  fprintf(fd, 'i%03d.tif %0.3f\n', zc, zc * vsize(3));
end
fprintf(fd, 'end\n');
  
% Close the file stream
fclose(fd);