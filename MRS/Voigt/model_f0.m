function f0 = model_f0(T)
%
% Calculate the ppm shifts of NAA, Cr, Cho and water
% at temperature T in degC
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 4/28/00 Start from scratch

f0 = zeros(1,4);

f0(1) = 2.0 - 0.0118 * (T - 37);
f0(2) = 3.0 - 0.0118 * (T - 37);
f0(3) = 3.2 - 0.0118 * (T - 37);
f0(4) = 4.7;
