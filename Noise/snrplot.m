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
