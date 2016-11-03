function s = imreadstack(sdir, sform, imform, zinds)
% Read in a stack of 2D images
%
% s = imreadstack(sdir, sform, imform, zinds)
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

% Defaults
if nargin < 4; zinds = [1 2]; end

% Calculate total number of images to read
nz = diff(zinds) + 1;

% Get image information from first image in requested stack
fname = sprintf(sform, zinds(1));
pname = [sdir '\' fname];
info = imfinfo(pname, imform);
xydims = [info.Height info.Width];

% Make space for stack
s = zeros([xydims nz]);

% Create a waitbar
hwb = waitbar(0);

for z = zinds(1):zinds(2)
  
  % Construct the full file path
  fname = sprintf(sform, z);
  pname = [sdir '\' fname]; 
  
  % Check for existance of file
  if exist(pname,'file') == 2
    
    % Update matrix z index
    zc = z - zinds(1) + 1;
    
    % Update waitbar
    waitbar(zc/nz,hwb,sprintf('Loading %s',fname));
    
    % Load this slice
    s(:,:,zc) = imread(pname, imform);
    
  end
    
end

% Close the waitbar
close(hwb);

% Normalize image range
smax = max(s(:));
smin = min(s(:));
if smin == smax; smax = smin + 1; end
s = (s - smin) / (smax - smin);
