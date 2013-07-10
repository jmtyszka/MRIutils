function cmap = twoway(n)
% Signed red-white-blue colormap
%
% cmap = twoway(n)
%
% Generate a red-blue colormap with n levels for
% signed, zero-biased images.
% blue - pale blue - white - pink - red
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 07/01/2004 JMT Adapt from doppler.m (JMT)
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

% Default to 128 levels
if nargin < 1
  n = 128;
end

% Round n to power of 2
n = 2 ^ (round(log(n)/log(2)));

% Fractions of cmap
hn = fix(n/2);

% Quarter ramp
hramp_up = linspace(0,1,hn)';
hramp_dwn = linspace(1,0,hn)';

% Make space for the colormap
cmap = zeros(n, 3);

% H1 desaturate blue
H1 = 1:hn;
cmap(H1,1) = hramp_up;
cmap(H1,2) = hramp_up;
cmap(H1,3) = 1.0;

% Q2 blue to mid-gray
H2 = H1 + hn;
cmap(H2,1) = 1.0;
cmap(H2,2) = hramp_dwn;
cmap(H2,3) = hramp_dwn;