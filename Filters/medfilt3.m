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
