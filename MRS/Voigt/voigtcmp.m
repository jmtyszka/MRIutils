function [f, Vm, Vmex] = voigtcmp
%
% Compare results of M and MEX versions of voigt
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 05/24/00 Start from scratch

nsamp = 256;
maxdV = zeros(1,nsamp);
mindV = zeros(1,nsamp);

for c = 1:nsamp
   f = -1.0:0.001:1;
   I = rand(1,1) * 10;
   f0 = rand(1,1) - 0.5;
   gL = rand(1,1);
   gD = rand(1,1);
   phi = pi*(rand(1,1)-0.5);
   
   Vm = voigt(f,I,f0,gL,gD,phi);
   Vmex = voigt_mex(f,I,f0,gL,gD,phi);
   dV = Vm - Vmex;
   
   maxdV(c) = max(dV);
   mindV(c) = min(dV);
end

fprintf('E(max,min dV) = [%g, %g]\n', mean(maxdV), mean(mindV));
fprintf('sd(max,min dV) = [%g, %g]\n', std(maxdV), std(mindV));