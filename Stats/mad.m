function m = mad(x)
% Return median absolute deviation from the median of a matrix
%
% AUTHOR : Mike Tyszka
% PLACE  : Caltech
% DATES  : 10/05/2012 JMT From scratch

x = x(:);
m = median(abs(x - median(x)));