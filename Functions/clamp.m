function x = clamp(x,xlo,xhi)
% Clamp values in a matrix to a range
%
% x = clamp(x,xlo,xhi)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 03/06/2002 JMT From scratch (about time)
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

x(x>xhi) = xhi;
x(x<xlo) = xlo;