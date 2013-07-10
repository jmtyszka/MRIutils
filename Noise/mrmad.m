function [madx,sdx,medx] = mrmad(x)
% MAD and SD estimates from N-D data
%
% [madx,sdx] = mrmad(x)
%
% Calculate median absolute deviation from the median (MAD)
% and robust estimate of the sd assuming Gaussian distribution.
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 02/13/2004 JMT From scratch
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2004-2006 California Institute of Technology.
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

% Flatten to column vector
x = x(:);

% Median absolute deviation from the median
medx = median(x);
madx = median(abs(x - medx));

% Robust SD estimate assuming Gaussian distribution
sdx = madx / 0.6745;