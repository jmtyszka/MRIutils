function m = moment3(s, morder)
% Calculate the m-order spatial moments of a 3D matrix
%
% m = moment3(s, morder)
%
% AUTHOR : Mike Tyszka, Ph.D
% PLACE  : Caltech BIC
% DATES  : 11/07/2000 JMT From scratch
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2000-2006 California Institute of Technology.
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

% Grab size of data
[nx,ny,nz] = size(s);

% Useful constants
hx = (nx-1)/2;
hy = (ny-1)/2;
hz = (nz-1)/2;

% Create coordinate grids
[x, y, z] = ndgrid(-hx:hx, -hy:hy, -hz:hz);

% Calculate spatial products
px = s .* (x.^morder);
py = s .* (y.^morder);
pz = s .* (z.^morder);

% Calculate moments as integrals over the volume
m = [sum(px(:)) sum(py(:)) sum(pz(:))];
