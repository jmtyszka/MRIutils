function [psi_uw, mask] = unwrap2dstack(psi_w, mag)
% Phase unwrap a 2D stack of images by 2D region growing
%
% [psi_uw, mask] = unwrap2dstack(psi_w, mag)
%
% ARGS:
% psi  = wrapped 2D stack of phase images
% mask = binary mask for each phase image
%
% RETURNS:
% phi = unwrapped 2D stack of phase images
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 06/16/2000 JMT Implement for first time
%          01/17/2006 JMT M-Lint corrections
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

nz = size(psi_w,3);

% Make space for the mag mask
mask = zeros(size(psi_w));
psi_uw = zeros(size(psi_w));

for z = 1:nz

  % Estimate the noise from the bottom left corner of this slice
  Sn = mag(1:8,1:8);
  sd_n = median(abs(Sn(:))) / 0.6745;

  % Call the MEX function
  [psi_uw(:,:,z), mask(:,:,z)] = ...
      MEX_Unwrap2D(psi_w(:,:,z), mag(:,:,z), 2 * sd_n);
  
end

