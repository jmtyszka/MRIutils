function y = iqr(x)
% y = iqr(x)
%
% Calculate inter-quartile range of x(:)
%
% ARGS:
% x = array of values (vector or matrix)
%
% RETURNS:
% y = inter-quartile range of x(:)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte CA
% DATES  : 10/09/2001 From scratch

y = diff(percentile(x,[25 75]));
