function sr = robustscale(s, newlims, plim)
% Percentile rescale N-D data
%
% sr = robustscale(s, newlims, plim)
%
% Rescale an image to the percentile limits specified.
% Clamp values outside of this range.
%
% ARGS:
% s       = nD scalar dataset
% newlims = destination image limits [0 1]
% plim    = optional percentile source limits [low hi] [5 95]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 10/24/2003 JMT Adapt from robustrange.m (JMT)
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

% Default arguments
if nargin < 1; return; end
if nargin < 2; newlims = [0 1]; end
if nargin < 3; plim = [5 95]; end

% Get percentile limits
lims = robustrange(s,plim);

% Intensity transform
sr = (s - lims(1)) / (diff(lims) + eps) * diff(newlims) + newlims(1);

% Clamp values
sr(sr < newlims(1)) = newlims(1);
sr(sr > newlims(2)) = newlims(2);