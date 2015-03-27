function [k_corr, x_optim, optres] = rare_phaseoptim(k_s0,k,ky_order,corr_type)
% [k_corr, x_optim, optres] = rare_phaseoptim(k_s0,k,ky_order,corr_type)
%
% Estimate per-echo phase correction for DW-RARE data by ghost
% minimization
%
% Operate on a reduced k-space in x and z for efficiency and higher phase SNR.
%
% Assumes k-space is correctly ordered for reconstruction and that ky_order
% maps the original ky ordering onto the correct locations in k-space.
%
% RETURNS:
% k_corr = k-space corrected by optimized phase
% x_optim = optimized parameters
% optres = optimization results
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 09/19/2007 JMT From scratch
%
% Copyright 2007 California Institute of Technology.
% All rights reserved.

% Debug mode
debug = 0;

% Optimization options
options = optimset('lsqnonlin');

% Get echo train length
etl = size(ky_order,2);

% Crop to k-space center in x and z
[nx,ny,nz] = size(k);
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

%% Create outside mask
s0_c = abs(fftshift(fftn(k_s0_c)));
s0_c = s0_c / max(s0_c(:));
outside = s0_c < graythresh(s0_c(:));

%% Initial estimate of phase offset for each echo

% Estimate the phase offset of each echo
% Returns a row vector
[dphi_echo_est,dphi_y_est,dphi_y] = rare_echo_phase_est(dphi,ky_order);

% Fill parameter structure
pars.k = k_c;
pars.nx = nx;
pars.ny = ny;
pars.nz = nz;
pars.etl = etl;
pars.ky_order = ky_order;
pars.outside = outside;
pars.corr_type = corr_type;

% Initial squared 2-norm residual
s_raw = abs(fftshift(fftn(k_c)));
resnorm_raw = norm(s_raw(pars.outside))^2;

% Initial per-echo phase estimate
switch corr_type
  case 'phase'
    x_est = rand(1,etl) * 2 * pi;
    x_lb = -Inf * ones(1,etl);
    x_ub = Inf * ones(1,etl);
  case 'complex'
    x_est = ones(1,2*etl);
    x_lb(1:etl) = -Inf * ones(1,etl);
    x_ub(1:etl) = Inf * ones(1,etl);
    x_lb((1:etl)+etl) = 0.5 * ones(1,etl);
    x_ub((1:etl)+etl) = 1.5 * ones(1,etl);
  otherwise
    fprintf('Unknown correction type %s\n',type);
end

% Optimize phase corrections
fprintf('Optimizing with estimated initial phases\n');
[x_optim,resnorm_est,residual,exitflag,output_est] = ...
  lsqnonlin('rare_phaseoptim_costfn',x_est,x_lb,x_ub,options,pars);

% Record optimization results
optres.resnorm_raw = resnorm_raw;
optres.resnorm_est = resnorm_est;
optres.iters_est = output_est.iterations;
optres.dphi_y_est = dphi_y_est;
optres.dphi_y = dphi_y;

% Apply optimized phase correction
pars.k = k;
k_corr = rare_apply_echo_corr(x_optim,pars);

% Optimize from random initial phase for debugging
if debug
  
  % Random initial guess
  dphi_echo_rand = rand(size(dphi_echo_est)) * 2 * pi;
  
  % Optimize from random initial guess
  fprintf('Optimizing with random initial phases\n');
  [dphi_echo_optim_rand,resnorm_rand,residual,exitflag,output_rand] = ...
    lsqnonlin('jmt_ddr_costfn',dphi_echo_rand,[],[],options,pars);

  % Record optimization results
  optres.resnorm_rand = resnorm_rand;
  optres.iters_rand = output_rand.iterations;

end

