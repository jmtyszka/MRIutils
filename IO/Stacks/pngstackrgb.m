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
