function rgb = flame(n)
% Classic black-purple-red-orange-yellow colormap
%
% cmap = flame(n)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 07/18/2005 JMT From doppler.m (JMT)
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
if nargin < 1; n = 128; end

% Round n to power of 2
n = 2 ^ (round(log(n)/log(2)));

% Hue increases linearly from 0.75 to 1, then 0 to 0.25
h = mod(linspace(0.75, 1.25, n), 1);

% Saturation decreases as power law
s = linspace(1, 0, n) .^ 0.5;

% Value increases as power law
v = linspace(0, 1, n) .^ 0.5;

% Covert to rgb
hsv = [h(:) s(:) v(:)];
rgb = hsv2rgb(hsv);

