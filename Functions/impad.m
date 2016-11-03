function y = impad(x, dims)
% Pad and/or crop a 2D image to the size specified.
%
% y = impad(x, dims)
%
% Dimensions are independent, so one may be cropped while
% the other is padded.
%
% ARGS :
% x    = input 2D image
% dims = desired pad/crop size
%
% RETURNS :
% y    = padded/cropped image
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 07/01/2002 JMT From scratch
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

% Default destination size
if nargin < 2
  dims = size(x);
end

% Check for 2D image
if ndims(dims) ~= 2
  help impad;
end

% Determine source and destination dimensions
[nx_s, ny_s] = size(x);
nx_d = dims(1);
ny_d = dims(2);

% Padding and cropping differences
dx = nx_s - nx_d;
dy = ny_s - ny_d;

% Determine x crop/pad transform
if dx > 0
  % x dimension needs cropping
  x_s = (1:nx_d) + fix(dx/2);
  x_d = 1:nx_d; 
else
  % x dimension needs padding
  x_s = 1:nx_s;
  x_d = (1:nx_s) - fix(dx/2);
end

% Determine y crop/pad transform
if dy > 0
  % y dimension needs cropping
  y_s = (1:ny_d) + fix(dy/2);
  y_d = 1:ny_d; 
else
  % y dimension needs padding
  y_s = 1:ny_s;
  y_d = (1:ny_s) - fix(dy/2);
end

% Fill destination with zeros
y = zeros(dims);

% Copy source to destination with cropping and padding
y(x_d,y_d) = x(x_s,y_s);
