function [mask, s_mask] = mrimask(s)
% Noise-based intensity mask for MR images
%
% USAGE : [mask, s_mask] = mrimask(s)
%
% Determine intensity mask threshold by searching for the first local
% minimum above the noise peak in the intensity histogram
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 09/19/2007 JMT From scratch
%          03/20/2014 JMT Update comments
%          2015-03-27 JMT Cast mask to doubles before return
%
% The MIT License (MIT)
%
% Copyright (c) 2016 Mike Tyszka
%
%   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
%   documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
%   rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
%   permit persons to whom the Software is furnished to do so, subject to the following conditions:
%
%   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
%   Software.
%
%   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
%   WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
%   COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
%   OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
mask = double(s > x_thresh);
s_mask = s .* mask;

if debug
  
  fprintf('Threshold at %0.3f\n', x_thresh);
  
  figure(1); clf
  bar(x,n);
  line([x_thresh x_thresh],[0 max(n(:))]);
  
end
