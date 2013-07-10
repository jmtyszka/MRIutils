function [sn, sd_n] = snrplot(s, lims, z)
% Display a noise-normalized, colorized central image from a data set
%
% SYNTAX: [sn, sd_n] = snrplot(s, lims, z)
%
% ARGS:
% s = 3D MRI volume
% lims = intensity limits for figure (same units as image values)
% z = slice to extract for figure
%
% AUTHOR: Mike Tyszka
% PLACE : Caltech Brain Imaging Center
% DATES : 10/22/2009 JMT From scratch
%         06/24/2011 JMT Update comments
%
% Copyright 2009-2011 California Institute of Technology
% All rights reserved.

if nargin < 1
  help snrplot
  return
end

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
fprintf('Normlizing image noise\n');
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
