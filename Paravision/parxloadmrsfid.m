function [k, info] = parxloadmrsfid(serdir)
% [k, info] = parxloadmrsfid(imnddir)
%
% Load a Paravision MRS fid into a complex vector
% Also return the exam information.
%
% ARGS:
% serdir = series directory containing the fid file
%
% RETURNS:
% k    = complex double k-space data
% info = info structure generated from Parx files
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 06/06/2001 Adapt from parxloadfid
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

fname = 'parxloadmrsfid';

% Set path separation character
sep = pathsep;

% Initialize return argument
k = [];

% Load info from this series directory
info = parxloadinfo(serdir);

if strcmp(info.name,'Unkown')
  fprintf('%s: Could not load study information\n', fname);
  return
end

% Assume fid file is in serdir
fidname = [serdir sep 'fid'];

% Open the file
fd = fopen(fidname,'r','ieee-be');
if (fd < 1)
  fprintf('%s: Could not open %s to read\n', fname, fidname);
  return
end

% Read the data
switch info.depth
case 32
  d = fread(fd, Inf, 'int32');
case 16
  d = fread(fd, Inf, 'int16');
otherwise
  fprintf('%s: Unknown bit depth (%s)\n', fname, info.depth);
  return;
end

% Close the file
fclose(fd);

% Grab length of fid
nsamps = length(d);

% Recompose into a complex vector
k = complex(d(1:2:nsamps),d(2:2:nsamps));
