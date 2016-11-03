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

% Figure flag
do_figure = true;

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

% Allocate matrix for slice-wise correlations of each IC spatial mode with Nyquist mask
nyquist_corr = zeros(nz, nics);

% Loop over all spatial ICs
for ic = 1:nics
  
  % Extract signed IC
  this_ic = IC_smodes(:,:,:,ic);
  
  % Flatten IC in XY to match mask (nx * ny) x nz
  this_ic = reshape(this_ic, nx * ny, nz);
  
  % Correlation matrix for spatial mode vs Nyquist mask on a slice basis (nz x nz)
  % Use the signed Nyquist mask with signed spatial IC mode
  r_mat = corr(this_ic, nyquist_mask);
  
  % Save the leading diagonal of the correlation matrix as a column vector
  nyquist_corr(:, ic) = diag(r_mat);
  
end

% Take absolute correlation to allow for sign flips in IC
nyquist_corr = abs(nyquist_corr);

% Nyquist score = # of slices with spatial correlations > threshold
nyquist_score = sum(nyquist_corr > corr_thresh);

% Identify ICs with scores > threshold
is_nyquist = nyquist_score >= score_thresh;

% Convert to row vector
is_nyquist = is_nyquist(:)';

if do_figure
  
  % Zero correlations below threshold (for visualization)
  nyquist_corr_thresh = nyquist_corr .* (nyquist_corr > corr_thresh);
  
  figure(20); clf; colormap(jet);
  
  subplot(311), imagesc(nyquist_corr, [0 1]); axis tight xy
  xlabel('IC #');
  ylabel('Slice #');
  title('Nyquist Ghost Spatial Correlation');
  colorbar
  
  subplot(312), imagesc(nyquist_corr_thresh); axis tight xy
  xlabel('IC #');
  ylabel('Slice #');
  colorbar
  
  subplot(313), bar(nyquist_score);
  xlabel('IC #');
  ylabel('Score');
  
  drawnow
  
end
