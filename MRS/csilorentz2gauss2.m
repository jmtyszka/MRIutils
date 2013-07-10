function kb = csilorentz2gauss2(k,sw,T2,FWHM_gauss)
% Lorentz-Gauss conversion of CSI spectral dimension
%
% kb = csilorentz2gauss2(k,sw,T2,FWHM_gauss)
%
% Lorentz to Gaussian filter applied to spectral dimension
% of a 2D spatial, 1D spectral CSI dataset.
% Assume spectral dimension is first dimension
%
% ARGS :
% k    = complex CSI k-space (nf x nx x ny)
% sw   = spectral width in Hz
% T2   = estimated T2 relaxation time in seconds
% FWHM_gauss = required FWHM Gaussian linebroadening in Hz
%
% RETURNS:
% kb = line-broadened complex CSI k-space
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 01/29/2004 JMT Adapt from linebroaden.m (JMT)
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2004-2006 California Institute of Technology.
% All rights reserved.
%
% This file is part of MRutils.
%
% MRutils is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% MRutils is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with MRutils; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


if nargin < 3
  kb = [];
  return
end

% CSI dimensions
[nf,nx,ny] = size(k);

% Create the time domain (kf) vector
dt = 1/sw;
t = ((1:nf)-1)' * dt;

% Generate the Exponential and Gaussian time-domain filters
FWHM_exp = 1 / (pi * T2);
[S0,Hexp] = exp_tfilter(t, zeros(1,nf), -FWHM_exp);
[S0,Hgauss] = gauss_tfilter(t, zeros(1,nf), FWHM_gauss);
Ht = Hexp .* Hgauss;

% Replicate in spatial dimensions
Ht = repmat(reshape(Ht,[nf 1 1]),[1 nx ny]);

% Apply filter
kb = Ht .* k;