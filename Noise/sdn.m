function sd = sdn(m, n)
% Estimate noise sd
%
% sd = sdn(m, n)
%
% Estimate noise sd from a samp of size n x n x n of 
% the 3D matrix, m. Assumes corner at origin is noise only.
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 09/27/2000 JMT From scratch
% DATES  : 01/17/2006 JMT M-Lint corrections
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

% Extract sample
msamp = m(1:n,1:n,1:n);
msamp = msamp(:);

% Use median absolute deviation from the median
% Assume Gaussian noise -> 0.6745 factor
sd = median(abs(msamp - median(msamp))) / 0.6745;