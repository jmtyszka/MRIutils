function [M0, T2, C, S_fit] = t2fit(TE,S,mode,options,M0_0, T2_0, C_0)
% [M0, T2, C, S_fit] = t2fit(TE,S,mode,options)
%
% Fit the T2 contrast equation:
%
%   S(TE) = M0 * exp(-TE/T2) + C
%
% ARGS:
% TE    = echo time vector for the final dimension
% S     = N-D matrix with echo time as final dimension
% mode  = 'constrained', 'unconstrained' or 'regression'
% options = options structure for lsqcurvefit
% M0_0, T2_0, C_0 = optional initial estimates
%
% RETURNS:
% M0 = S(TE=0) matrix
% T2 = T2 matrix in ms
% C  = constant offset
% S_fit = fitted relaxation curve
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 09/06/2001 Adapt from t1fit

if nargin < 3 mode = 'constrained'; end
if nargin < 4
  % Optimization options
  options = optimset('lsqcurvefit');
  options = optimset(options,...
    'TolFun',1e-4,...
    'TolX',1e-4,...
    'Jacobian','on',...
    'Display','off');
end
if nargin < 5; M0_0 = []; end
if nargin < 5; T2_0 = []; end
if nargin < 5; C_0 = []; end

if isempty(M0_0) || M0_0 == 0; M0_0 = S(1); end
if isempty(T2_0) || T2_0 == 0; T2_0 = TE(1); end
if isempty(C_0); C_0 = 0; end

% Initial guess vector
x0 = [M0_0 T2_0 C_0];

% Constraints
switch mode
  case 'constrained'
    xmin = [-Inf 0 -Inf];
    xmax = [Inf Inf Inf];
  case 'unconstrained'
    xmin = [];
    xmax = [];
    options.LargeScale = 'off';
  case 'regression'
    M0 = exp(p(2));
    T2 = -1/p(1);
    C  = 0;
    S_fit = M0 * exp(-TE/T2) + C;
    return
end

% Perform fit
x = lsqcurvefit('lsq_t2contrast', x0, TE, S, xmin, xmax, options);

% Recalculate the fitted relaxation curve
S_fit = lsq_t2contrast(x,TE);

% Return fit results
M0 = x(1);
T2 = x(2);
C  = x(3);