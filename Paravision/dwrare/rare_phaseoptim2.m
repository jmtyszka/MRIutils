function [k_corr, x_optim, optres] = rare_phaseoptim2(k, ky_order, corr_type)
% [k_corr, dphi_echo_optim, optres] = rare_phaseoptim2(k,ky_order,corr_type)
%
% Estimate per-echo phase correction for DW-RARE data by ghost minimization
% without using a reference phase. Operate on a reduced k-space in x and z
% for efficiency and higher phase SNR. Assumes k-space is correctly ordered
% for reconstruction and that ky_order maps the original ky ordering onto
% the correct locations in k-space.
%
% ARGS:
% k = complex k-space acquired using a RARE sequence
% ky_order = original ky line index order (nshots x etl)
% corr_type = 'phase' or 'complex' per-echo correction
%
% RETURNS:
% k_corr  = k-space corrected by optimized phase
% x_optim = optimized parameters
% optres  = detailed optimization results
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 09/19/2007 JMT From scratch
%          02/26/2008 JMT Adapt from rare_phaseoptim
%
% Copyright 2007-2008 California Institute of Technology.
% All rights reserved.

if nargin < 3; type = 'phase'; end

% Optimization options
options = optimset('lsqnonlin');
options.Display = 'none';

% Determine echo train length from ky_order matrix
etl = size(ky_order,2);

% Crop to k-space center in x (2D and 3D) and z (3D only)
[nx,ny,nz] = size(k);
nk = 8;    
xinds = (-nk:(nk-1))+fix(nx/2);
if nz < 8
  zinds = 1;
else
  zinds = (-nk:(nk-1))+fix(nz/2);
end

% Apply k-space crop
k_c = k(xinds,:,zinds);

% Reconstruct low-res magnitude image
s_c = abs(fftshift(fftn(fftshift(k_c))));
s_c = s_c / max(s_c(:));

% Create outside mask using Otsu threshold
outside = s_c < graythresh(s_c);

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
resnorm_raw = norm(s_c(pars.outside))^2;

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
[x_optim,resnorm_est,~,~,output_est] = ...
  lsqnonlin('rare_phaseoptim2_costfn',...
  x_est, x_lb, x_ub,...
  options, pars);

% Record optimization results
optres.resnorm_raw = resnorm_raw;
optres.resnorm_est = resnorm_est;
optres.iters_est = output_est.iterations;

% Apply optimized phase correction
pars.k = k;
k_corr = rare_apply_echo_corr(x_optim, pars);