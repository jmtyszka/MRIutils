function cmap = redblue(n)
% Signed red-blue colormap
%
% cmap = redblue(n)
%
% Generate a red-blue colormap with n levels for
% signed, zero-biased images.
% blue/white - blue - black - red - pink
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 09/28/2000 JMT From scratch
%          01/15/2003 JMT Update to color doppler type scale
%          01/17/2006 JMT M-Lint corrections
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

% Default to 128 levels
if nargin < 1
  n = 128;
end

% Round n to power of 2
n = 2 ^ (round(log(n)/log(2)));

% Fractions of cmap
qn = fix(n/4);

% Quarter ramp
qramp_up = linspace(0,1,qn)';
qramp_dwn = linspace(1,0,qn)';

% Make space for the colormap
cmap = zeros(n, 3);

% Q1 blue-white to blue
Q1 = 1:qn;
cmap(Q1,1) = qramp_dwn * 0.9;
cmap(Q1,2) = qramp_dwn * 0.9;
cmap(Q1,3) = 1.0;

% Q2 blue to black
Q2 = Q1 + qn;
cmap(Q2,1) = 0.0;
cmap(Q2,2) = 0.0;
cmap(Q2,3) = qramp_dwn;

% Q3 black to red
Q3 = Q2 + qn;
cmap(Q3,1) = qramp_up;
cmap(Q3,2) = 0.0;
cmap(Q3,3) = 0.0;

% Q4 red to pink
Q4 = Q3 + qn;
cmap(Q4,1) = 1.0;
cmap(Q4,2) = qramp_up * 0.9;
cmap(Q4,3) = qramp_up * 0.9;
