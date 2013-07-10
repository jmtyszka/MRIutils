function [is_outside, outside_score] = find_outside_ics(IC_smodes, brain_mask, outside_thresh, score_thresh)
% Identify spatial ICs with high correlation to Nyquist ghost regions
%
% USAGE:
% [is_outside, nyquist_corr] = find_nyquist_ics(IC_smodes, brain_mask, outside_thresh, score_thresh)
%
% ARGS:
% IC_smodes       = Melodic .ica directory containing IC results [pwd]
% brain_mask      = brain mask from ICA
% outside_thresh  = per slice threshold for fraction of suprathreshold signal outside brain
% score_thresh    = Outside score threshold
%
% RETURNS:
% is_outside    = logical vector for Nyquist-like spatial ICs
% outside_score = Nyquist score : number of slices > correlation threshold
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 07/09/2013 JMT Adapt from find_nyquist_ics
%
% Copyright 2013 California Institute of Technology.
% All rights reserved.

% Default Nyquist correlation threshold
if nargin < 3; outside_thresh = 0.4; end
if nargin < 4; score_thresh = 1; end

% Require all arguments
if nargin < 1
  fprintf('USAGE: [is_outside, outside_score] = find_nyquist_ics(IC_smodes, brain_mask, outside_thresh, score_thresh)\n');
  return
end

% Get dimensions
[nx, ny, nz, nics] = size(IC_smodes);

% Flatten XY in mask - separate outside fraction for each z slice
brain_mask = reshape(brain_mask, nx * ny, nz);

% Outside mask is logical NOT of brain mask
outside_mask = ~brain_mask;

% Allocate outside score vector
outside_score = zeros(nics,1);

% Loop over all spatial ICs
for ic = 1:nics
  
  % Take absolute value of IC - avoid self cancellation during averaging
  % this_ic = abs(IC_smodes(:,:,:,ic));

  % Signed averaging
  this_ic = IC_smodes(:,:,:,ic);
  
  % Flatten IC in XY to match mask
  this_ic = reshape(this_ic, nx * ny, nz);
  
  % Calculate fraction of total IC signal outside brain
  outside_sum = sum(this_ic .* outside_mask);
  brain_sum = sum(this_ic .* brain_mask);
  outside_frac = outside_sum ./ (outside_sum + brain_sum);
  
  % Outside score = number of slices with outside fraction > threshold
  outside_score(ic) = numel(find(outside_frac > outside_thresh)); 
  
end

% Identify ICs with sufficient number of slices with outside fraction >
% threshold
is_outside = outside_score >= score_thresh;

% Convert to row vector
is_outside = is_outside(:)';
