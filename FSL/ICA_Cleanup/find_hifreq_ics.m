function [is_hifreq, hifreq_frac] = find_hifreq_ics(IC_tmodes, TR, hifreq_cutoff, hifreq_frac_thresh)
% Identify ICs with high frequency temporal modes (likely respiratory)
%
% USAGE: 
% [hifreq_ics, hifreq_frac] = find_hifreq_ics(IC_tmodes, TR, hifreq_cutoff, hifreq_frac_thresh)
%
% ARGS:
% IC_tmodes = Melodic .ica directory containing IC results [pwd]
% TR = Sequence TR in seconds [2.0]
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

% Output flag
do_figure = false;

% Require all arguments
if nargin < 1
  fprintf('USAGE: [is_hifreq, hifreq_frac] = find_hifreq_ics(IC_tmodes, TR, hifreq_cutoff, hifreq_frac_thresh)\n');
  return
end

% Calculate complete power spectrum
pspec = abs(fft(IC_tmodes,[],1)).^2;

% Combine positive and negative frequency bins.
% Result is half spectrum of absolute frequencies.
nf = size(pspec,1);

% Handle both odd and even spectrum length
% hf = fix(nf/2)
% Even spectrum : positive freqs from 1:hf, negative from (hf:-1:1)+hf
% Odd spectrum  : positive from 1:hf, negative from ((hf+1):-1:1)+hf
% Discard highest negative frequency point for odd spectrum length to allow
% positive and negative spectrum averaging

hf = fix(nf/2);
pspec_pos = pspec(1:hf,:);
pspec_neg = pspec((hf:-1:1)+hf,:);

% Average positive and negative frequency spectra
pspec = pspec_pos + pspec_neg;

% Adjust spectrum length to half spectrum
nf = hf;

% Calculate cumulative sum for all spectra
pspec_cumsum = cumsum(pspec,1);

% Time axis
[nt,nics] = size(IC_tmodes);
t = ((1:nt)-1) * TR;

% Nyquist frequency (Hz)
f_N = 0.5/TR;

% Frequency axis
f = linspace(0,f_N,nf);

% Find index corresponding to cutoff frequency
ic = round(hifreq_cutoff / f_N * nf);

% Calculate fraction of total spectral power above cutoff frequency
hifreq_frac = 1 - pspec_cumsum(ic,:) ./ max(pspec_cumsum,[],1);

% Identify ICs exceeding the threshold for spectral power above the cutoff
% frequency (ie high frequency ICs)
is_hifreq = hifreq_frac > hifreq_frac_thresh;

% Convert to row vector
is_hifreq = is_hifreq(:)';

%% High frequency IC analysis figure

if do_figure
  
  figure(10); clf; colormap(hot);
  
  % Sort ICs in order of fraction of power > cutoff
  [~, order] = sort(hifreq_frac);
  
  subplot(131), imagesc(1:nics, t, IC_tmodes(:,order));
  
  subplot(132), imagesc(1:nics, f, pspec(:,order));
  xlabel('Sorted ICs');
  ylabel('Frequency (Hz)');
  
  subplot(133), bar(hifreq_frac(order));
  xlabel('Sorted ICs');
  ylabel('High frequency fraction');
  axis tight
  
end
