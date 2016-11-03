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
% The MIT License (MIT)
%
% Copyright (c) 2016 Mike Tyszka
%
%   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
%   documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
%   rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
%   permit persons to whom the Software is furnished to do so, subject to the following conditions:
%
%   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
%   Software.
%
%   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
%   WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
%   COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
%   OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
