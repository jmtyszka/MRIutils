function [is_nyquist, nyquist_score] = find_nyquist_ics(IC_smodes, nyquist_mask, corr_thresh, score_thresh)
% Identify spatial ICs with high correlation to Nyquist ghost regions
%
% USAGE:
% [is_nyquist, nyquist_corr] = find_nyquist_ics(IC_smodes, nyquist_mask, corr_thresh, score_thresh)
%
% ARGS:
% IC_smodes    = Melodic .ica directory containing IC results [pwd]
% nyquist_mask = Nyquist region mask (FOV/2 shifted main image mask)
% corr_thresh  = per slice correlation threshold for Nyquist pattern
% score_thresh = Nyquist score threshold
%
% RETURNS:
% is_nyquist    = logical vector for Nyquist-like spatial ICs
% nyquist_score = Nyquist score : number of slices > correlation threshold
%
% Copyright 2013 California Institute of Technology.
% All rights reserved.

% Default Nyquist correlation threshold
if nargin < 3; corr_thresh = 0.4; end
if nargin < 4; score_thresh = 1; end

% Require all arguments
if nargin < 1
  fprintf('USAGE: [is_nyquist, nyquist_corr] = find_nyquist_ics(IC_smodes, nyquist_mask, corr_thresh, score_thresh)\n');
  return
end

% Get dimensions
[nx, ny, nz, nics] = size(IC_smodes);

% Flatten XY in mask - separate r for each z slice
nyquist_mask = reshape(nyquist_mask, nx * ny, nz);

% Allocate maximum Nyquist correlation vector
nyquist_score = zeros(nics,1);

% Loop over all spatial ICs
for ic = 1:nics
  
  % Take absolute value of IC - Nyquist mask is positive only
  this_ic = abs(IC_smodes(:,:,:,ic));
  
  % Flatten IC in XY to match mask
  this_ic = reshape(this_ic, nx * ny, nz);
  
  % r is a correlation matrix (nx * ny) x nz
  r_mat = corr(this_ic, nyquist_mask);
  
  % We're only interested in the leading diagonal
  r = diag(r_mat);
  
  % Nyquist score = number of slices with spatial correlation with Nyquist
  % mask > corr_thresh
  nyquist_score(ic) = numel(find(r > corr_thresh)); 
  
end

% Identify ICs with sufficient number of slices with spatial correlation >
% corr_thresh
is_nyquist = nyquist_score >= score_thresh;

% Convert to row vector
is_nyquist = is_nyquist(:)';
