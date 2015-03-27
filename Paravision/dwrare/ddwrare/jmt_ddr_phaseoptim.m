function [k_corr, dphi_y, dphi_y_est, dphi_y_optim, optres] = jmt_ddr_phaseoptim(k_s0,k,info,debug)
% Operate on a reduced k-space in x and z for efficiency and higher phase
% SNR.
%
% RETURNS:
% k_corr = k-space corrected by optimized phase
% dphi_y = raw projection of phase onto y/RARE axis (1 x ny)
% dphi_y_est = estimated phase projection (1 x ny)
% dphi_y_optim = optimized echo phase offset (1 x ny)
% optres = optimization results
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 09/19/2007 JMT From scratch
%
% Copyright 2007 California Institute of Technology.
% All rights reserved.

% Optimization options
options = optimset('lsqnonlin');

% Crop to k-space center in x and z
[nx,ny,nz] = size(k);
nk = 8;    
xinds = (-nk:(nk-1))+fix(nx/2);
zinds = (-nk:(nk-1))+fix(nz/2);

k_s0_c = k_s0(xinds,:,zinds);
k_c = k(xinds,:,zinds);

% Calculate phase difference between cropped DWI and reference k-spaces
dphi = angle(k_c) - angle(k_s0_c);

%% Create outside mask
s0_c = abs(fftshift(fftn(k_s0_c)));
s0_c = s0_c / max(s0_c(:));
outside = s0_c < graythresh(s0_c(:));

%% Initial estimate of phase offset for each echo

% Estimate the phase offset of each echo
% Returns a row vector
etl = info.etl;
nshots = fix(ny/etl);
[dphi_echo_est,dphi_y_est,dphi_y] = jmt_ddr_echo_phase_est(dphi,nshots,etl);

% Fill parameter structure
pars.k = k_c;
pars.nx = nx;
pars.ny = ny;
pars.nz = nz;
pars.nshots = nshots;
pars.outside = outside;
pars.debug = debug;

% Initial squared 2-norm residual
s_raw = abs(fftshift(fftn(k_c)));
optres.resnorm_raw = norm(s_raw(pars.outside))^2;

% Calculate initial residual norm for estimated phase correction
res_est_0 = jmt_ddr_costfn(dphi_echo_est,pars);
optres.resnorm_est_0 = norm(res_est_0)^2;

% Optimize phase corrections
fprintf('Optimizing with estimated initial phases\n');
[dphi_echo_optim, resnorm_est, residual, exitflag, output_est] = ...
  lsqnonlin('jmt_ddr_costfn',dphi_echo_est,[],[],options,pars);

% Record optimization results
optres.resnorm_estoptim = resnorm_est;
optres.iters_estoptim = output_est.iterations;

% Optimize from random initial phase for debugging
if debug
  
  % Random initial guess
  dphi_echo_rand = rand(size(dphi_echo_est)) * 2 * pi;
  
  % Calculate initial residual norm for random phase correction
  res_rand_0 = jmt_ddr_costfn(dphi_echo_rand,pars);
  optres.resnorm_rand_0 = norm(res_rand_0)^2;
  
  % Optimize from random initial guess
  fprintf('Optimizing with random initial phases\n');
  [dphi_echo_optim_rand,resnorm_rand, residual, exitflag, output_rand] = ...
    lsqnonlin('jmt_ddr_costfn',dphi_echo_rand,[],[],options,pars);

  % Record optimization results
  optres.resnorm_randoptim = resnorm_rand;
  optres.iters_randoptim = output_rand.iterations;

end

% Replicate echo phase to fill ky dimension
dphi_y_optim = repmat(dphi_echo_optim,[nshots 1]);
dphi_y_optim = dphi_y_optim(:)';

% Replicate phase correction to full k-space
dphi_corr = repmat(dphi_y_optim,[nx 1 nz]);

% Apply optimized phase correction
k_corr = k .* exp(-i * dphi_corr);