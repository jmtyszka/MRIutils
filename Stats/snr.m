function [sn,sd_n] = snr(s)
% Estimate the SNR of an image.
%
% SYNTAX : [sn,sd_n] = snr(s)
%
% Estimates noise sd from the MAD of the detail coefficients of a wavelet
% decomposition of the image.
%
% ARGS:
% s = nD image
%
% RETURNS:
% sn = signal-to-noise ratio of image
% sd_n = noise sd
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATE   : 06/17/2002 From scratch
%          10/22/2009 Add comments
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

% Flatten image and count voxels
s = s(:);
n = length(s);

% Estimate sample noise sd
sd_n = noisesd(s);

% Find 95 percentile signal intensity
p95_s = percentile(s,95);

% Estimate SNR
sn = p95_s / sd_n;

fprintf('\nIMAGE SNR ESTIMATE\n\n');
fprintf('  Noise sd              : %0.3g\n', sd_n);
fprintf('  Image 95th Percentile : %0.3g\n', p95_s);
fprintf('  SNR                   : %0.1f\n\n', sn);
