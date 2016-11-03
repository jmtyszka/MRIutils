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
