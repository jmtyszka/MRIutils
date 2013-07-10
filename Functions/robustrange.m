function minmax = robustrange(s, plim, ns)
% Calculate a percentile range for N-D data
%
% minmax = robustrange(s, plim, ns)
%
% Calculate the robust range of s[] using plim(1,2)
% as the minimum and maximum percentile range.
% ns = number of samples to take (default is n/10 and < 1000)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte CA
% DATES  : 04/24/2001 JMT Adapt from MEPSI_RobustRange.m
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

if isempty(s)
  minmax = [0 1];
  return
end

% Flatten s
s = s(:);

% Default args
if nargin < 2; plim = [10 99]; end
if nargin < 3; ns = min([1000 length(s)/10]); end

if ns > length(s)
  ns = length(s);
end

% Random sample of s
isamp = fix(rand(1, fix(ns)) * length(s)) + 1;
ssamp = s(isamp);

% Sort the sample
ns = length(ssamp);
ssort = sort(ssamp);

% Find the index in the sorted vector of the minimum percentile
imin = round(plim(1)/100 * ns);
if (imin < 1); imin = 1; end

% Ditto for the maximum
imax = round(plim(2)/100 * ns);
if (imax > ns); imax = ns; end

% Return the values of ss[] at these indices
minmax = [ssort(imin) ssort(imax)];