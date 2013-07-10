function v_r = voigt_real(f, gL, gD)
%
% V = voigt(f, gL, gD)
%
% Generate the real Voigt lineshape with f0 = I0 = phi =0
% Used for lineshape integration.
%
% f   = Frequency vector
% gL  = Lorentzian width
% gD  = Doppler (Gaussian) width 
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 04/28/00 Start from memory
%          05/08/00 Create real, zero offset Voigt function

v_r = real(voigt(f, 1.0, 0.0, gL, gD, 0.0));