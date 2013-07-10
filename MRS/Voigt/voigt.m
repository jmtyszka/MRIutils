function V = voigt(f, I0, f0, gL, gD, phi)
%
% V = voigt(f, I0, f0, gL, gD, phi)
%
% Generate a complex Voigt lineshape
%
% f   = Frequency vector
% I0  = Amplitude
% f0  = Central frequency
% gL  = Lorentzian width
% gD  = Doppler (Gaussian) width 
% phi = Phase in radians
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 4/28/00 Start from memory
% REFS   : Armstrong BH J Quant Spectrosc Radiat Transfer 1967; 7:61-88

% Numerical scale for x and y
A = sqrt(log(2)) / gD;

x = (f-f0) * A;
y = gL * A;

% humlicek() returns an approximation to w(z), the Voigt/Fadeeva function
% The complex conjugate of w(z) gives the correct phase for NMR spectra
[V, V0] = humlicek_mex(x,y);

% Normalize V to 1.0 then scale by I0 exp(i phi)
V = I0 * exp(i * phi) * conj(V) / V0; 
