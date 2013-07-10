function [mask, s_mask] = mrimask(s)
% [mask, s_mask] = mrimask(s)
%
% Determine intensity mask threshold by searching for the first local
% minimum above the noise peak in the intensity histogram
%
% AUTHOR : Mike Tyszka, Ph.D.
% DATES  : 09/19/2007 JMT From scratch
% PLACE  : Caltech
%
% Copyright 2007 California Institute of Technology.
% All rights reserved.

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
