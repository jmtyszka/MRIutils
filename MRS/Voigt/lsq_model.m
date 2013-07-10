function y = lsq_model(x, f)
%
% Least-square curve fitting function
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 4/28/00 Start from scratch

% Extract parameters
I   = x(1:4);
f0  = x(5:8);
gL  = x(9:12);
gD  = x(13:16);
phi = x(17:20);

% Calculate the complex model spectrum
y_cmplx = model_mrs(f, I, f0, gL, gD, phi);

% Flatten the channels into one double-length vector
y = [real(y_cmplx) imag(y_cmplx)];
