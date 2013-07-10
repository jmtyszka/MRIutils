function H = fermi(n, fr, fw, tails)
% H = fermi(n, fr, fw, tails)
%
% Return the 1D Fermi filter function
%
% ARGS:
% n  = number of filter points
% fr = fractional filter radius
% fw = fractional filter transition width
% tails = lower, upper or two-sided filter
%         ('lower','upper','both') ['both']
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech Biological Imaging Center
% DATES  : 10/28/2003 JMT Adapt from fermi3.m (JMT)
%          03/22/2004 JMT Add tails argument

% Default arguments
if nargin < 1 n = 128; end
if nargin < 2 fr = 0.5; end
if nargin < 3 fw = 0.05; end
if nargin < 4 tails = 'both'; end

% Construct a normalized coordinate
x = ((1:n)-1) / n - 0.5;

% Construct 1D Fermi filter vector
H = 1 ./ (1 + exp((abs(x) - fr(1))/fw(1)));

% Asymmetry adjustments
switch tails
  case 'lower'
    H(fix(n/2):n) = 1.0;
  case 'upper'
    H(1:fix(n/2)) = 1.0;
  otherwise
    % Do nothing
end
