function y = percentile(x, p)
% y = percentile(x, p)
%
% Calculate the p'th percentile of the vector x
%
% ARGS:
% x = array of values
% p = vector of percentiles to be calculated
%
% RETURNS:
% y = vector of percentiles corresponding to p
%
% AUTHOR  : Mike Tyszka, Ph.D.
% PLACE   : City of Hope, Duarte CA
% DATES   : 02/20/2001 From scratch
%           10/09/2001 Add support for multiple percentiles
%#realonly

% Flatten the vectors
x = x(:);
p = p(:);
n = length(x);

% Catch single point
if n < 2
  y = repmat(x(1),size(p));
  return
end

% Sort the vector
sx = sort(x);

% Find fractional percentile indices
inds = (n * p / 100) + 0.5;

% Keep index in bounds
inds(inds > n) = n;
inds(inds < 1) = 1;

% Interpolate percentile
y = interp1(1:n, sx, inds, '*linear');
