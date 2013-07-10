function s2 = medianqt(s)
% Decompose the 2D image s() by a factor of 2
%
% s2 = medianqt(s)
%
% Each quadtree node is the median of its branches
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 06/23/2000 JMT From scratch
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2003-2006 California Institute of Technology.
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

[nrow, ncol] = size(s);

nrow2 = nrow/2;
ncol2 = ncol/2;

% Make space for new downsampled image
s2 = zeros(nrow2, ncol2);

for c = 1:ncol2

  % Extract the first column -> 2 x nrow
  colinds = 2 * (c-1) + (0:1) + 1;
  scol = s(:, colinds)';

  % Reshape scol() so that each quad forms a row -> 4 x nrow2
  scol = reshape(scol, 4, nrow2);

  % Find medians of the rows of scol()
  % This forms the c'th column of the downsampled data
  s2(:,c) = median(scol, 1)';

end
