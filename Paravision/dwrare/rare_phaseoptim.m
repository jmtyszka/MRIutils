function [k_corr, optres] = rare_phaseoptim(k_s0, k, ky_order)
% [k_corr, x_optim, optres] = rare_phaseoptim(k_s0,k,ky_order,corr_type)
%
% Estimate per-echo phase correction for DW-RARE data using phase reference
% (typically the unweighted S(0) k-space). Operate on a reduced k-space in
% x and z for efficiency and higher phase SNR. Assumes k-space is correctly
% ordered for reconstruction and that ky_order maps the original ky
% ordering onto the correct locations in k-space.
%
% ARGS:
% k_s0 = complex reference RARE k-space
% k = complex diffusion-weighted RARE k-space
% ky_order = original ky line index order (nshots x etl)
% corr_type = 'phase' or 'complex' per-echo correction
%
% RETURNS:
% k_corr = k-space corrected by optimized phase
% x_optim = optimized parameters
% optres = optimization results
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 09/19/2007 JMT From scratch
%          2015-04-05 JMT Switch to median phase estimate from cropped
%                         k-space
%
% Copyright 2007-2015 California Institute of Technology.
% All rights reserved.

% Optimization options
options = optimset('lsqnonlin');
options.Display = 'none';

% Determine echo train length from ky_order matrix
etl = size(ky_order,2);

% Crop to k-space center in x and z
[nx,~,nz] = size(k);
nk = 8;    
xinds = (-nk:(nk-1))+fix(nx/2);
if nz < 8
  zinds = 1;
else
  zinds = (-nk:(nk-1))+fix(nz/2);
end

k_s0_c = k_s0(xinds,:,zinds);
k_c = k(xinds,:,zinds);

% Calculate phase difference between cropped DWI and reference k-spaces
dphi = angle(k_c) - angle(k_s0_c);

%% Initial estimate of phase offset for each echo

% Estimate the phase offset of each echo
% Returns a row vector
[dphi_echo_est, dphi_y_est, dphi_y] = rare_echo_phase_est(dphi,ky_order);

optres.dphi_y_est = dphi_y_est;
optres.dphi_y     = dphi_y;

% Allocate phase correction volume
echo_corr = zeros(size(k));

% Replicate current per-echo correction across whole k-space volume
% Use ky_order to handle phase encoding order
for ec = 1:etl
  echo_corr(:,ky_order(:,ec),:) = exp(1i * dphi_echo_est(ec));
end

% Apply correction
k_corr = k .* echo_corr;

