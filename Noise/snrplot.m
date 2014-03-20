function [sn, sd_n] = snrplot(s, lims, z)
% Display a noise-normalized, colorized central image from a data set
%
% SYNTAX: [sn, sd_n] = snrplot(s, lims, z)
%
% ARGS:
% s    = 3D MRI volume
% lims = intensity limits for figure (same units as image values)
% z    = slice to extract for figure [central z slice]
%
% AUTHOR: Mike Tyszka
% PLACE : Caltech Brain Imaging Center
% DATES : 10/22/2009 JMT From scratch
%         06/24/2011 JMT Update comments
%         03/20/2014 JMT Update comments
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
% Copyright 2009,2011,2014 California Institute of Technology.

if nargin < 1
  help snrplot
  return
end

% Default arguments
if nargin < 2; lims = []; end
if nargin < 3; z = fix(size(s,3)/2); end

% Check dimensionality of data
switch ndims(s)
  case 2
    sxy = s;
  case 3
    sxy = s(:,:,z)';
    sxy = flipud(sxy);
  otherwise
    fprintf('Unsupported image dimensionality: %d\n', ndims(s));
    return
end

% Estimate SNR
fprintf('Estimating image SNR\n');
[sn, sd_n] = snr(s);

% Normalize image noise to 1
fprintf('Normalizing image noise\n');
sxy = sxy / sd_n;

% Display colorized result
figure(1); clf
colormap(jet);

if isempty(lims)
  imagesc(sxy);
else
  imagesc(sxy,lims);
end

axis equal off
colorbar;
