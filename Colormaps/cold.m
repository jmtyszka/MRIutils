function cmap = cold(n)
% Cold colormap based on channel reordering of the hot colormap
%
% cmap = cold(n)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 02/21/2005 JMT From scratch
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2005-2006 California Institute of Technology.
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

% Default to 128 levels
if nargin < 1
  n = 128;
end

% Round n to power of 2
n = 2 ^ (round(log(n)/log(2)));

hc = hot(n);
cmap(:,1) = hc(:,3);
cmap(:,2) = hc(:,2);
cmap(:,3) = hc(:,1);