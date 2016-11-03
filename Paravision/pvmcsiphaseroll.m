function kr = pvmcsiphaseroll(k,info)
% kr = pvmcsiphaseroll(k,info)
%
% Apply the phase rolls from the reco file (RECO_rotate) as
% linear phasings to a 3D CSI k-space.
%
% ARGS :
% k    = 3D complex k-space data (kf,kx,ky)
% info = info structure for Paravision dataset (info.recorot[])
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 01/07/2004 JMT Adapt from dtiphaseroll.m (JMT)
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

% Grab k-space dimensions
[nkf,nkx,nky] = size(k);

% k-space coordinate vectors for each dimension
kf = ((1:nkf)-1) - nkf/2;
kx = ((1:nkx)-1) - nkx/2;
ky = ((1:nky)-1) - nky/2;

% Normalized k-space coordinate grids
[kfg,kxg,kyg] = ndgrid(kf,kx,ky);

% Setup fractional offsets in each dimension
ff = 0.5;
fx = info.recorot(2);
fy = info.recorot(3);

% Generate combined linear phase function
phi = exp(-2 * pi * i * (ff * kfg + fx * kxg + fy * kyg));

% Apply phase functions
kr = k .* phi;
