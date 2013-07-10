function y = lsq_ircontrast(x, TI)
%
% lsqcurvefit function for Inversion Recovery
%
% Mz(t) = M0 * (1 + E1 * (alpha - 1))
%
% x = [M0 alpha T1]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 11/09/2000 From scratch

E1 = exp(-TI/x(3));

y = x(1) * (1 + E1 * (x(2) - 1));