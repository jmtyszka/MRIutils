function S = CoilNoiseRatio
% Calculate sample noise to coil noise ratio for ranges of B0 and sample radius
%
% USAGE : S = CoilNoiseRatio
%
% AUTHOR : Mike Tyszka
% PLACE  : Caltech BIC
% DATES  : 06/17/2002 From scratch
%          03/20/2014 Update comments
% REFS   : Mansfield and Morris
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
% Copyright 2002,2013 California Institute of Technology.

% log range of B0 to consider
logB = -2:0.2:1;

% B0 range in Tesla
B = 10.^logB;

% Corresponding 1H frequency range in Hz
f = 4.2e6 * B;

% log object radius range to consider
logR = -3:0.1:1;

% Radius range in meters
R = 10.^logR;

% Create coordinate grid
[allf, allR] = meshgrid(R,f);

% Calculate sample noise / coil noise ratio
S = allf.^2 .* allR.^2 ./ sqrt(allf.^2 * allR.^3 + A * f.^0.5);

% Contour plot of SNR 
contour(allf,allR,S);
