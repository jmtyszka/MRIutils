function H = gauss_coeff(n, hw)
%
% Calculate filter coefficients for an n point Gaussian
% with FWHM of <s> points
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte, CA
% DATES  : 5/31/00 Start from scratch

s = hw / sqrt(8*log(2));
t = ((1:n) - fix(n/2) - 1) / s;
H = exp(-0.5 * t.*t);
H = H / sum(H);
