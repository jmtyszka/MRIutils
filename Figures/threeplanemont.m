function tp = threeplanemont(s,clims)
% Create a three-plane montage from a 3D dataset.
%
% tp = threeplanemont(s,clims)
%
% Allow specification of intensity limits and colormap.
%
% ARGS :
% s     = 3D dataset
% clims = colormap limits
% sp    = subplot parameters [nx ny Axloc Sagloc Corloc] eg [2 2 1 2 3]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte CA
% DATES  : 09/07/2001 JMT Adapt from montagegray
%          06/20/2002 JMT Add colormap argument
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

% Defaults if arguments aren't passed
if nargin < 1
  help threeplane
  return
end

if nargin < 2; clims = []; end
if isempty(clims); clims = [min(s(:)) max(s(:))]; end

% Catch equal limits
if diff(clims) == 0
  clims = [min(s(:)) max(s(:))];
end

% Get new dimensions
[nx,ny,nz] = size(s);
hx = round(nx/2);
hy = round(ny/2);
hz = round(nz/2);

% Clamp s[] to these limits
s(s < clims(1)) = clims(1);
s(s > clims(2)) = clims(2);

% Extract axial, sagittal and coronal midline sections
Ax  = squeeze(s(:,:,hz))';
Sag = flipdim(squeeze(s(hx,:,:))',2);
Cor = squeeze(s(:,hy,:))';

% Determine maximum vertical dimension
dims = [size(Ax); size(Sag); size(Cor)];

% Find maximum dimensions of any orthogonal slice
newdims = max(dims);

Ax  = impad(Ax,newdims);
Sag = impad(Sag,newdims);
Cor = impad(Cor,newdims);

% Montage the three planes
tp = [Ax Sag Cor];
