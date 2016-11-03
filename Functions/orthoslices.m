function [s_xy,s_xz,s_yz] = orthoslices(s)
% Extract central XY, XZ and YZ planes from a 3D image
%
% SYNTAX : [xy,xz,yz] = orthoslices(s)
% PLACE  : Caltech 
% DATES  : 12/16/2008 JMT From scratch
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

if nargin < 1; return; end

% Check for non-3D image
if ndims(s) ~= 3
  fprintf('Image is not 3D\n');
  return
end

% Determine image size
[nx,ny,nz] = size(s);

% Central slice locations in each dimension
hx = fix(nx/2); hy = fix(ny/2); hz = fix(nz/2);

% Extract orthogonal central slices
s_xy = squeeze(s(:,:,hz));
s_xz = squeeze(s(:,hy,:));
s_yz = squeeze(s(hx,:,:));
