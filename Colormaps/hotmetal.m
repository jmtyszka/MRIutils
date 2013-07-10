function cmap = hotmetal(n)
% Hot metal colormap
%
% cmap = hotmetal(n)
%
% Hot metal colormap runs through:
%   black
%   dark blue
%   purple
%   red
%   orange
%   yellow
%   white
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 09/27/2004 JMT Adapt from twoway.m (JMT)
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

% Round n to a multiple of 6
n = fix(n/6)*6;

% Fractions of cmap
n6 = fix(n/6);

% Ramps (sixth of range)
ramp_up = linspace(0,1,n6)';
ramp_dwn = linspace(1,0,n6)';

% Make space for the colormap
cmap = zeros(n, 3);

% black to blue
E1 = 1:n6;
cmap(E1,1) = 0.0;
cmap(E1,2) = 0.0;
cmap(E1,3) = ramp_up/2;

% blue to purple
E2 = E1 + n6;
cmap(E2,1) = ramp_up/2;
cmap(E2,2) = 0.0;
cmap(E2,3) = 0.5;

% purple to red
E3 = E2 + n6;
cmap(E3,1) = ramp_up/2 + 0.5;
cmap(E3,2) = 0.0;
cmap(E3,3) = ramp_dwn/2;

% red to orange
E4 = E3 + n6;
cmap(E4,1) = 1.0;
cmap(E4,2) = ramp_up/2;
cmap(E4,3) = 0.0;

% orange to yellow
E5 = E4 + n6;
cmap(E5,1) = 1.0;
cmap(E5,2) = ramp_up/2 + 0.5;
cmap(E5,3) = 0.0;

% yellow to white
E6 = E5 + n6;
cmap(E6,1) = 1.0;
cmap(E6,2) = 1.0;
cmap(E6,3) = ramp_up;