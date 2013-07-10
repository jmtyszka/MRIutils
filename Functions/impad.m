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
