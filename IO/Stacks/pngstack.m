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
