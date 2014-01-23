function [is_slicebg, max_slicebg_score] = find_slicebg_ics(IC_smodes, mask, score_thresh)
% Identify spatial ICs with abnormally high background signal in one or two slices
%
% USAGE:
% [is_slicebg, slicebg_score] = find_slicebg_ics(IC_smodes, bg_mask, score_thresh)
%
% ARGS:
% IC_smodes       = Melodic .ica directory containing IC results [pwd]
% background_mask = Background region mask
% score_thresh    = slice score threshold
%
% RETURNS:
% is_slicebg        = logical vector for bad slice BG spatial ICs
% max_slicebg_score = maximum MAD ratio (score) for each IC
%
% Copyright 2013 California Institute of Technology.
% All rights reserved.

% Figure flag
do_figure = true;

% Default background signal noise threshold
if nargin < 3; score_thresh = 1; end

% Require at least 2 arguments
if nargin < 2
  fprintf('USAGE: [is_slice_bg, slice_bg_score] = find_slice_background_ics(IC_smodes, bg_mask, score_thresh)\n');
  return
end

% Get dimensions
[nx, ny, nz, nics] = size(IC_smodes);

% Allocate matrix for slice-wise correlations of each IC spatial mode with background mask
slicebg_score = zeros(nz, nics);

% Loop over all spatial ICs
for ic = 1:nics
  
  % Extract signed IC
  this_ic = IC_smodes(:,:,:,ic);
  
  % NaN out brain voxels
  this_ic(mask) = NaN;
  
  % Calculate MAD over all background voxels (assumes zero meaned noise)
  bg_mad = nanmedian(abs(this_ic(:)));
  
  % Flatten xy planes
  this_ic = reshape(this_ic, (nx * ny), nz);
  
  % Calculate ratio of slice-wise background MADs to global background MAD
  % Generates a 1 x nz vector of MAD ratios (ie slice scores)
  this_ic_z = nanmedian(abs(this_ic), 1) / bg_mad;
  
  % Normalize to MAD and save in a matrix
  slicebg_score(:, ic) = this_ic_z;
  
end

% Identify ICs with MAD ratios > threshold
bad_slices = slicebg_score > score_thresh;

% Count number of bad slices for each IC
n_bad_slices = sum(bad_slices);

% Slice background ICs have between 1 and 2 bad slices
is_slicebg = n_bad_slices >= 1 & n_bad_slices <= 2;

% Return maximum slice score for each IC
max_slicebg_score = max(slicebg_score);

% Convert to row vectors for return
is_slicebg = is_slicebg(:)';
max_slicebg_score = max_slicebg_score(:)';

if do_figure
  
  figure(30); clf; colormap(jet);
  
  subplot(311), imagesc(slicebg_score); axis tight xy
  xlabel('IC #');
  ylabel('Slice #');
  title('Slice Background Score');
  colorbar
  
  subplot(312), imagesc(bad_slices); axis tight xy
  xlabel('IC #');
  ylabel('Slice #');
  title('Bad slices');
  colorbar
   
%   subplot(313), bar(slicebg_score);
%   xlabel('IC #');
%   ylabel('Score');
  
  drawnow
  
end
