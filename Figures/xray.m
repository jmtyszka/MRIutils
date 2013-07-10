function xray(s, projmeth)
% Display three-plane projections through a 3D dataset
%
% xray(s, projmeth)
%
% ARGS :
% s = 3D scalar image
% projment = 'xray' or 'mip'
%
% RETURNS :
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 07/25/2002 JMT From scratch
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

if nargin < 2; projmeth = 'mip'; end

switch projmeth
case 'mip'
  sx = squeeze(max(s,[],1))';
  sy = squeeze(max(s,[],2))';
  sz = squeeze(max(s,[],3));
otherwise
  sx = squeeze(mean(s,1))';
  sy = squeeze(mean(s,2))';
  sz = squeeze(mean(s,3));
end

subplot(221), imagesc(sx);
title('Coronal','Color','w');
axis equal xy;
set(gca,'XColor','w','YColor','w');

subplot(223), imagesc(sy);
title('Sagittal','Color','w');
axis equal xy;
set(gca,'XColor','w','YColor','w');

subplot(224), imagesc(sz);
title('Axial','Color','w');
axis equal xy;
set(gca,'XColor','w','YColor','w');