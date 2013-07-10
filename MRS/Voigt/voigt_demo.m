function voigt_demo
%
% Demonstrate the Voigt lineshape
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 4/28/00 Start from scratch

N = 256;

df = 1/N;

f   = -1:df:(1-df);
I   = 1.0;
f0  = 0.0;
gL  = 0.1;
gD  = 0.1;
phi = 0.0;

V = voigt_mex(f, I, f0, gL, gD, phi);

plot(f, real(V), f, imag(V));
