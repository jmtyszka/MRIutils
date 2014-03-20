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
%          03/20/2014 JMT Update comments
%
% This file is part of MRIutils.
%
%     MRIutils is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     MRIutils is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with MRIutils.  If not, see <http://www.gnu.org/licenses/>.
%
% Copyright 2004,2006,2013 California Institute of Technology.

% Flatten to column vector
x = x(:);

% Median absolute deviation from the median
medx = median(x);
madx = median(abs(x - medx));

% Robust SD estimate assuming Gaussian distribution
sdx = madx / 0.6745;
