function [s_est, b_est, x_est] = refine_fit(f, s_expt, b_est, x_est, T)
%REFINE_FIT Subtract baseline estimate from s_expt

n = length(f);

% Subtract baseline estimate from s_expt
s = s_expt - b_est;

% Flatten the spectrum channels into one double-length vector
s_lsq = [real(s) imag(s)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setup for optimization

% Bounds for the parameters
Imin   = zeros(1,4);
f0min  = model_f0(T) - 0.1;
gLmin  = 0.001 * ones(1,4);
gDmin  = 0.001 * ones(1,4);
phimin = -Inf * ones(1,4);

Imax   = Inf * ones(1,4);
f0max  = model_f0(T) + 0.1;
gLmax  = 0.1 * ones(1,4);
gDmax  = 0.1 * ones(1,4);
phimax = Inf * ones(1,4);

% Initial guess vector and limits
xmin = [Imin f0min gLmin gDmin phimin];
xmax = [Imax f0max gLmax gDmax phimax];

% Options for the curve fitting
options = optimset('lsqcurvefit');
options.TolX = 1e-4;
options.TolFun = 1e-4;
options.MaxIter = 100;

% Non-linear least-squares fit of the model spectrum
% to the synthetic spectrum
x = lsqcurvefit('lsq_model', x_est, f, s_lsq, xmin, xmax, options);

% Calculate the best fit model spectrum
s_est_lsq = lsq_model(x, f);
s_est = s_est_lsq(1:n) + i * s_est_lsq((1:n) + n);

% Update baseline estimate
b_est = s_expt - s_est;

% Smooth the baseline using a polynomial fit
porder = 6;
[P] = polyfit(f, b_est, porder);
b_est = polyval(P, f);

% Return the optimized parameter estimates
x_est = x;

