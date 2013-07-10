function [s_xy,s_xz,s_yz] = orthoslices(s)
% Extract central XY, XZ and YZ planes from a 3D image
%
% SYNTAX : [xy,xz,yz] = orthoslices(s)
% PLACE  : Caltech 
% DATES  : 12/16/2008 JMT From scratch
%
% Copyright 2008 California Institute of Technology.
% All rights reserved.

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