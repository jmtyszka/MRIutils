function zmotion_ics = find_zmotion_ics(ica_dir, p_thresh)
% Identify physiological ICs from temporal mode power distribution
%
% USAGE: 
% zmotion_ics = find_zmotion_ics(ica_dir, p_thresh)
%
% ARGS:
% ica_dir = Melodic .ica directory containing IC results [pwd]
% p_thresh = detection threshold for Nyquist power [0.25]
%
% RETURNS:
% f_physio = fraction of spectral power above 0.1Hz
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

% Operational flags
verbose = 1;

% Nyquist power threshold
if nargin < 2; p_thresh = 0.25; end

% Load 4D melodic IC data
ic = load_nii(fullfile(ica_dir,'melodic_IC.nii.gz'));

% Grab number of slices (z dimension)
nz = size(ic,3);

% Collapse X,Y dimensions
ic_zi = squeeze(mean(mean(ic,1),2));

% Calculate power spectra for z dimension
p_zi = abs(fft(ic_zi,[],1)).^2;

% Column normalize power spectra
p_zi_norm = p_zi ./ repmat(sum(p_zi),[nz 1]);

% Sum power at Nyquist and neighbors
nyq = fix(nz/2)+1;
p_i_sum = sum(p_zi_norm((nyq-1):(nyq+1),:));

% Return mask for zmotion ICs
zmotion_ics = p_i_sum > p_thresh;

% Optional results figure
if verbose
  
  subplot(311), imagesc(ic_zi);
  subplot(312), imagesc(p_zi_norm);
  subplot(313), bar(p_i_sum); axis tight
  
  fprintf('Z-motion ICs\n');
  disp(find(zmotion_ics));
  
end
