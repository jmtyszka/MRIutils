function Rrgb = overlayrgb(Argb, Brgb, qA, qB, cmode)
% Composite two RGB transparent images using a given mode
%
% Rrgb = overlayrgb(Argb, Brgb, qA, qB, cmode)
%
% ARGS:
% Argb  = RGB image A
% Brgb  = RGB image B
% qA    = Opacity of image A
% qB    = Opacity of image B
% cmode = Compositing mode : 'normal', 'multiply', 'screen', 'lighten', 'darken'
%
% RETURNS:
% Rrgb  = Composited RGB image
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 02/21/2001 JMT From scratch
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

fname = 'overlayrgb';

% Default return
Rrgb = [];

% Check parameters
if nargin < 5
  cmode = 'normal';
end
if nargin < 4
  fprintf('SYNTAX : %s(Argb, Brgb, qA, qB, cmode)\n', fname);
  return
end

% Check opacities
if qA < 0 || qB < 0 || qA > 1 || qB > 1
  fprintf('%s: Transparencies must be in range 0..1\n', fname);
  return
end

% Check image dimensions
[nxA, nyA, ncA] = size(Argb);
[nxB, nyB, ncB] = size(Brgb);

if nxA ~= nxB || nyA ~= nyB
  fprintf('%s: Images must have the same dimensions\n', fname);
  return
end

if ncA ~= 3 || ncB ~= 3
  fprintf('%s: Images must be RGB (nx x ny x 3)\n', fname);
  return
end

switch lower(cmode)
case 'normal'
  Rrgb = qA * Argb + Brgb; % A transparently overlays B
case 'overlay'
  Rrgb = Brgb .* (Brgb + (2 * Argb .* (1 - Brgb)));
case 'multiply'
  Rrgb = qA * Argb + qB * Brgb + Argb .* Brgb;
case 'screen'
  Rrgb = Argb + Brgb - Argb .* Brgb;
case 'lighten'
  Rrgb = min(cat(3, qB * Brgb + Argb, qA * Argb + Brgb),[],3);
case 'darken'
  Rrgb = max(cat(3, qB * Brgb + Argb, qA * Argb + Brgb),[],3);
otherwise
  fprintf('%s: Unknown composite mode %s\n', fname, cmode);
  return
end

% Finally clamp RGB values to range 0..1
Rrgb(Rrgb > 1) = 1;
Rrgb(Rrgb < 0) = 0;
