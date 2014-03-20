function [mask, s_mask] = mrimask(s)
% Noise-based intensity mask for MR images
%
% USAGE : [mask, s_mask] = mrimask(s)
%
% Determine intensity mask threshold by searching for the first local
% minimum above the noise peak in the intensity histogram
%
% AUTHOR : Mike Tyszka, Ph.D.
% DATES  : 09/19/2007 JMT From scratch
%          03/20/2014 JMT Update comments
% PLACE  : Caltech
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
% Copyright 2007,2013 California Institute of Technology.

% Debug flag for verbose output
debug = 0;

% Subsample the image if voxel count is too large
nsamp = 1e4;
s_flat = s(:);
if length(s_flat) > nsamp
  rand('seed',66);
  inds = fix(rand(1,nsamp) * length(s_flat)) + 1;
  s_samp = s_flat(inds);
else
  s_samp = s_flat;
end


% Number of histogram bins. 128 seems reasonably fine scale
nbin = 128;

% Create histogram
[n,x] = hist(s_samp,nbin);

% First derivative of histogram
dn = diff(n);

% Quickly find zero crossings
zeros_plus = find(dn(1:(nbin-2)) < 0.0 & dn(2:(nbin-1)) > 0.0);

% Determine threshold intensity at first zero crossing
% This marks the upper boundary of the noise peak
x_thresh = x(zeros_plus(1)+1);

% Create intensity mask and apply to image
mask = s > x_thresh;
s_mask = s .* mask;

if debug
  
  fprintf('Threshold at %0.3f\n', x_thresh);
  
  figure(1); clf
  bar(x,n);
  line([x_thresh x_thresh],[0 max(n(:))]);
  
end
