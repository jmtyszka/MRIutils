function Q = voigt_area(I0, gL, gD)
%
% Q = voigt_area(A, gL, gD)
%
% Estimates the [-Inf,Inf] integral of the real
% Voigt lineshape using Gaussian quadrature.
% Assumes no contribution to integral beyond
% 100 * max(gL,gD).
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope National Medical Center
% DATES  : 05/08/00 Continue from previous Matlab code by JMT
%          06/01/00 Use Matlab quad8 rather than user contrib gaussq
%                   Change upper limit to 100 * max(gL,gD)
%                   Back to gaussq - no itteration limit errors

p = 1e3 * max([gL gD]);

Q0 = I0 * gaussq('voigt_real', 0, p, [], [], gL, gD);

Q = real(2 * Q0);
