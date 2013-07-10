function [S0, T2] = mefit(ME, TE)
% [S0, T2] = mefit(ME, TE)
%
% Fit the T2 contrast equation:
%
%   ME(TE) = S0 * exp(-TE/T2)
%
% to the last dimension of an N-D matrix, S[]
%
% ARGS:
% ME = N-D matrix with echo time as final dimension
% TE = echo time vector for the final dimension
%
% RETURNS:
% S0 = S(TE=0) matrix
% T2 = T2 matrix in ms
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 09/06/2001 Adapt from irfit

options = optimset('lsqcurvefit');
options.Display = 'none';

x0   = [ME(1) min(TE)];
xmin = [0 0];
xmax = [Inf Inf];

x = lsqcurvefit('lsq_mecontrast', x0, TE, ME, xmin, xmax, options);

S0 = x(1);
T2 = x(2);

% Plot result and hold
% ME_fit = lsq_mecontrast(x, TE);
% plot(TE, ME, 'o', TE, ME_fit);