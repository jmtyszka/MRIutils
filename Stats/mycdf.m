function cdf = mycdf(x,s)
% cdf = mycdf(x,s)
%
% Calculate the cumulative distribution function of a sample s[] for the given ordinates x[]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte CA
% DATES  : 10/10/2001 From scratch

cdf = zeros(size(x));

for xc = 1:length(x)
  cdf(xc) = sum(s < x(xc));
end

cdf = cdf / length(s);
