function y = t2contrast(x, TE)
%
% T2 contrast function with DC offset
%
%   ME(TE) = S0 * exp(-TE/T2) + C
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 09/06/2001 From scratch

y = x(1) * exp(-TE./x(2)) + x(3);
