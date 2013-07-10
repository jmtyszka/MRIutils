function b = medfilt3(a, k)
% Perform a hybrid 2D-3D median filter of a 3D dataset
%
% b = medfilt3(a, k)
%
% Run the conventional 2D median filter over the data in
% the XY, XZ and YZ planes.
%
% ARGS:
% b = 3D matrix of any type
% k = kernel dimension
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 07/19/2001 JMT From scratch
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

if nargin < 2; k = 3; end
if ndims(k) > 1; k = k(1); end

% Make k next equal or larger odd number
k = fix(k/2)*2+1;
fprintf('Using a %d x %d kernel\n', k, k);

% Grab data dimensions
[nx,ny,nz] = size(a);

% XY planes

% Copy the source matrix to destination matrix
b = a;

fprintf('Filtering plane: XY');
for z = 1:nz
  b(:,:,z) = medfilt2(squeeze(a(:,:,z)), [k k]);
end

% XZ planes

% b is currently XYZ so permute to XZY
a = permute(b,[1 3 2]);
b = a; % Redimension b by copying a

fprintf(' XZ');
for y = 1:ny
  b(:,:,y) = medfilt2(squeeze(a(:,:,y)), [k k]);
end

% YZ planes

% b is currently XZY so permute to YZX
a = permute(b,[3 2 1]);
b = a; % Redimension b by copying a
  
fprintf(' YZ\n');
for x = 1:nx
  b(:,:,x) = medfilt2(squeeze(a(:,:,x)), [k k]);
end

% b is currently YZX to permute to XYZ
b = permute(b, [3 1 2]);